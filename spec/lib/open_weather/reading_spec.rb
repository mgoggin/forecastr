require "rails_helper"

RSpec.describe OpenWeather::Reading do
  subject(:instance) { described_class.new(current_conditions:, daily_forecast:, cached:) }

  let(:current_conditions) { instance_double("OpenWeather::CurrentConditions") }
  let(:daily_forecast) { instance_double("OpenWeather::DailyForecast") }
  let(:cached) { false }

  it { is_expected.to have_attributes(current_conditions:, daily_forecast:, cached:) }

  describe ".from_api" do
    subject(:result) { described_class.from_api(payload) }

    let(:payload) do
      {
        timezone: "America/New_York",
        current: {
          dt: Time.current.to_i,
          temp: 87.65
        },
        daily: [
          {
            dt: Time.current.to_i,
            temp: { day: 88.77 },
            summary: "foo"
          },
          {
            dt: Time.current.tomorrow.to_i,
            temp: { day: 77.66 },
            summary: "bar"
          }
        ]
      }
    end

    it "is expected to have appropriate attributes" do
      expect(result).to have_attributes(
        current_conditions: have_attributes(
          temperature: 87.65,
          recorded_at: a_kind_of(Time).and(have_attributes(zone: /E[D|S]T/))
        ),
        daily_forecast: match_array(
          [
            have_attributes(
              temperature: a_kind_of(OpenWeather::Temperature).and(have_attributes(current: 88.77)),
              forecasted_for: a_kind_of(Time).and(have_attributes(zone: /E[D|S]T/)),
              summary: "foo"
            ),
            have_attributes(
              temperature: a_kind_of(OpenWeather::Temperature).and(have_attributes(current: 77.66)),
              forecasted_for: a_kind_of(Time).and(have_attributes(zone: /E[D|S]T/)),
              summary: "bar"
            )
          ]
        ),
        cached: false
      )
    end

    context "when timezone is missing from the payload" do
      let(:payload) do
        {
          current: {
            dt: Time.current.to_i,
            temp: 87.65
          },
          daily: [
            {
              dt: Time.current.to_i,
              temp: { day: 88.77 },
              summary: "foo"
            },
            {
              dt: Time.current.tomorrow.to_i,
              temp: { day: 77.66 },
              summary: "bar"
            }
          ]
        }
      end

      it "is expected to fallback to UTC" do
        expect(result).to have_attributes(
          current_conditions: have_attributes(
            temperature: 87.65,
            recorded_at: a_kind_of(Time).and(have_attributes(zone: "UTC"))
          ),
          daily_forecast: match_array(
            [
              have_attributes(
                temperature: a_kind_of(OpenWeather::Temperature).and(have_attributes(current: 88.77)),
                forecasted_for: a_kind_of(Time).and(have_attributes(zone: "UTC")),
                summary: "foo"
              ),
              have_attributes(
                temperature: a_kind_of(OpenWeather::Temperature).and(have_attributes(current: 77.66)),
                forecasted_for: a_kind_of(Time).and(have_attributes(zone: "UTC")),
                summary: "bar"
              )
            ]
          ),
          cached: false
        )
      end
    end

    context "when payload is missing daily forecast data" do
      let(:payload) do
        {
          timezone: "America/New_York",
          current: {
            dt: Time.current.to_i,
            temp: 87.65
          }
        }
      end

      it { is_expected.to have_attributes(daily_forecast: be_empty) }
    end

    context "when payload has daily forecast data as an empty array" do
      let(:payload) do
        {
          timezone: "America/New_York",
          current: {
            dt: Time.current.to_i,
            temp: 87.65
          },
          daily: []
        }
      end

      it { is_expected.to have_attributes(daily_forecast: be_empty) }
    end

    context "when cached flag is passed in" do
      subject(:reading) { described_class.from_api(payload, cached: true) }

      it { is_expected.to have_attributes(cached: true) }
    end
  end
end
