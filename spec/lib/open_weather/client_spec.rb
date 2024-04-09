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
  end
end
