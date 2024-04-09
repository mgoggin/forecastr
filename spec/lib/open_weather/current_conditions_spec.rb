require "rails_helper"

RSpec.describe OpenWeather::CurrentConditions do
  subject(:instance) { described_class.new(temperature:, recorded_at:) }

  let(:temperature) { 72.123 }
  let(:recorded_at) { Time.current }

  it { is_expected.to have_attributes(temperature:, recorded_at:) }

  describe ".from_api" do
    subject(:result) { described_class.from_api(payload) }

    let(:payload) do
      {
        temp: 70.987,
        dt: Time.current.to_i
      }
    end

    it { is_expected.to have_attributes(temperature: 70.987, recorded_at: a_kind_of(Time)) }

    context "when temperature is not present in the payload" do
      let(:payload) { { dt: Time.current.to_i } }

      it { is_expected.to have_attributes(temperature: be_nil) }
    end

    context "when temperature is present containing a blank value" do
      let(:payload) { { temp: "  ", dt: Time.current.to_i } }

      it { is_expected.to have_attributes(temperature: be_nil) }
    end

    context "when temperature is present containing nil" do
      let(:payload) { { temp: nil, dt: Time.current.to_i } }

      it { is_expected.to have_attributes(temperature: be_nil) }
    end

    context "when recorded_at is not present in the payload" do
      let(:payload) { { temp: 72.45 } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":recorded_at must be a UNIX timestamp")
      end
    end

    context "when recorded_at is present containing a blank value" do
      let(:payload) { { temp: 72.45, dt: "  " } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":recorded_at must be a UNIX timestamp")
      end
    end

    context "when recorded_at is present containing nil" do
      let(:payload) { { temp: 72.45, dt: nil } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":recorded_at must be a UNIX timestamp")
      end
    end

    context "when recorded_at is not a UNIX timestamp" do
      let(:payload) { { temp: 72.45, dt: "foo" } }

      it "is expected to raise ArgumentError" do
        expect { result }.to raise_error(ArgumentError).with_message(":recorded_at must be a UNIX timestamp")
      end
    end
  end
end
