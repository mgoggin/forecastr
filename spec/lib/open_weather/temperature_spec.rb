require "rails_helper"

RSpec.describe OpenWeather::Temperature do
  subject(:instance) { described_class.new(current:, high:, low:) }

  let(:current) { 55.02 }
  let(:high) { 59.98 }
  let(:low) { 42.12 }

  it { is_expected.to have_attributes(current:, high:, low:) }

  describe ".from_api" do
    subject(:result) { described_class.from_api(payload) }

    let(:payload) do
      {
        day: 72.12,
        min: 56.09,
        max: 75.00
      }
    end

    it { is_expected.to have_attributes(current: 72.12, high: 75.00, low: 56.09) }

    context "when high temp is not present" do
      let(:payload) do
        {
          day: 72.12,
          min: 12.34
        }
      end

      it { is_expected.to have_attributes(high: be_nil) }
    end

    context "when low temp is not present" do
      let(:payload) do
        {
          day: 72.12,
          max: 123.45
        }
      end

      it { is_expected.to have_attributes(low: be_nil) }
    end

    context "when current temp is not present" do
      let(:payload) do
        {
          min: 32.00,
          max: 100.00
        }
      end

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":current must be provided")
      end
    end
  end
end
