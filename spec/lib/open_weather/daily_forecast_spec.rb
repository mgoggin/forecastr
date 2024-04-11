require "rails_helper"

RSpec.describe OpenWeather::DailyForecast do
  subject(:instance) { described_class.new(temperature:, forecasted_for:, summary:) }

  let(:temperature) { 72.42 }
  let(:forecasted_for) { Time.current.to_i }
  let(:summary) { "foo" }

  it { is_expected.to have_attributes(temperature:, forecasted_for:, summary:) }

  describe ".from_api" do
    subject(:result) { described_class.from_api(payload) }

    let(:payload) do
      {
        temp: {
          day: 70.12,
          min: 45.67,
          max: 87.65
        },
        dt: Time.current.to_i,
        summary: "foo"
      }
    end

    it "is expected to have appropriate attributes" do
      expect(result).to have_attributes(
        temperature: a_kind_of(OpenWeather::Temperature).and(
          have_attributes(
            current: 70.12,
            high: 87.65,
            low: 45.67
          )
        ),
        forecasted_for: a_kind_of(Time),
        summary: "foo"
      )
    end

    context "when temperature is not present in the payload" do
      let(:payload) { { dt: Time.current.to_i, summary: "foo" } }

      it { is_expected.to have_attributes(temperature: be_nil) }
    end

    context "when temperature is present containing a blank value" do
      let(:payload) { { temp: { day: "  " }, dt: Time.current.to_i, summary: "foo" } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":current must be provided")
      end
    end

    context "when temperature is present containing nil" do
      let(:payload) { { temp: { day: nil }, dt: Time.current.to_i, summary: "foo" } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":current must be provided")
      end
    end

    context "when forecasted_for is not present in the payload" do
      let(:payload) { { temp: { day: 72.45 }, summary: "foo" } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":forecasted_for must be a UNIX timestamp")
      end
    end

    context "when forecasted_for is present containing a blank value" do
      let(:payload) { { temp: { day: 72.45 }, summary: "foo", dt: "  " } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":forecasted_for must be a UNIX timestamp")
      end
    end

    context "when forecasted_for is present containing nil" do
      let(:payload) { { temp: { day: 72.45 }, summary: "foo", dt: nil } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":forecasted_for must be a UNIX timestamp")
      end
    end

    context "when forecasted_for is not a UNIX timestamp" do
      let(:payload) { { temp: { day: 72.45 }, summary: "foo", dt: "foo" } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":forecasted_for must be a UNIX timestamp")
      end
    end

    context "when summary is not present in the payload" do
      let(:payload) { { dt: Time.current.to_i, temp: { day: 69.98 } } }

      it { is_expected.to have_attributes(summary: be_nil) }
    end

    context "when summary is present containing a blank value" do
      let(:payload) { { temp: { day: 69.98 }, dt: Time.current.to_i, summary: "  " } }

      it { is_expected.to have_attributes(summary: be_nil) }
    end

    context "when summary is present containing nil" do
      let(:payload) { { temp: { day: 69.98 }, dt: Time.current.to_i, summary: nil } }

      it { is_expected.to have_attributes(summary: be_nil) }
    end
  end
end
