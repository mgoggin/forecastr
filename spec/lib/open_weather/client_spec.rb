require "rails_helper"
require "open_weather/client"

RSpec.describe OpenWeather::Client do
  subject(:instance) { described_class.new(api_key:) }

  let(:api_key) { Rails.application.credentials.open_weather_api_key }

  it { is_expected.to respond_to(:forecast) }

  describe "#forecast" do
    subject(:result) { instance.forecast(latitude, longitude) }

    let(:latitude) { 38.2207 }
    let(:longitude) { -90.396 }

    around do |example|
      VCR.use_cassette("forecast_festus_mo") do
        example.run
      end
    end

    it "is expected to make an HTTP request to the Open Weather API" do
      result

      expect(
        a_request(:get, "https://api.openweathermap.org/data/3.0/onecall")
          .with(
            query: {
              appid: api_key,
              lat: latitude,
              lon: longitude,
              exclude: "minutely,hourly,alerts",
              units: "imperial"
            }
          )
      ).to have_been_made
    end

    context "when a postal code is provided for caching", :aggregate_failures do
      subject(:result) { instance.forecast(latitude, longitude, "12345") }

      before do
        allow(Rails.cache).to receive(:exist?).and_call_original
        allow(Rails.cache).to receive(:read).and_call_original
        allow(Rails.cache).to receive(:write).and_call_original
      end

      it "is expected to use the Rails cache to cache the result" do
        result

        expect(Rails.cache).to have_received(:exist?).once
        expect(Rails.cache).to have_received(:write).once
      end

      context "when the result is already cached" do
        before do
          instance.forecast(latitude, longitude, "12345")
        end

        it "is expected to read the value from the cache" do
          result

          expect(Rails.cache).to have_received(:read).once
        end

        it "is expected not to write to the cache a second time" do
          result

          # This expectation picks up the initial write to the cache as configured in the before block.
          expect(Rails.cache).to have_received(:write).at_most(:once)
        end

        it "is expected not to call the Open Weather API" do
          result

          expect(a_request(:get, "https://api.openweathermap.org/data/3.0/onecall")).not_to have_been_made
        end

        context "when the expiration has passed" do
          it "is expected not to read the value from the cache" do
            result

            Timecop.travel(31.minutes.from_now) do
              # This expectation ensures that #read is only called once as in the expectation above.
              expect(Rails.cache).to have_received(:read).once
            end
          end

          it "is expected to call the Open Weather API" do
            result

            expect(
              a_request(:get, "https://api.openweathermap.org/data/3.0/onecall")
                .with(
                  query: {
                    appid: api_key,
                    lat: latitude,
                    lon: longitude,
                    exclude: "minutely,hourly,alerts",
                    units: "imperial"
                  }
                )
            ).to have_been_made
          end
        end
      end
    end
  end
end
