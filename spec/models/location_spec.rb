require "active_support/all"
require "spec_helper"
require File.expand_path("../../app/models/location", __dir__)

RSpec.describe Location do
  subject(:instance) { described_class.new(latitude:, longitude:, postal_code:) }

  let(:latitude) { nil }
  let(:longitude) { nil }
  let(:postal_code) { nil }

  it { is_expected.to have_attributes(latitude:, longitude:, postal_code:) }

  describe "#coordinates" do
    subject(:result) { instance.coordinates }

    it "is expected to raise RuntimeError" do
      expect { result }.to raise_error ":latitude and :longitude must both be provided"
    end

    context "when latitude and longitude are both provided" do
      let(:latitude) { 1 }
      let(:longitude) { 2 }

      it { is_expected.to eq "1, 2" }
    end

    context "when latitude only is provided" do
      let(:latitude) { 1 }

      it "is expected to raise RuntimeError" do
        expect { result }.to raise_error ":latitude and :longitude must both be provided"
      end
    end

    context "when longitude only is provided" do
      let(:longitude) { 2 }

      it "is expected to raise RuntimeError" do
        expect { result }.to raise_error ":latitude and :longitude must both be provided"
      end
    end
  end
end
