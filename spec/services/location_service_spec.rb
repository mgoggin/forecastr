require "rails_helper"

RSpec.describe LocationService do
  subject(:instance) { described_class.new(prefer_country_code:) }

  let(:prefer_country_code) { "us" }

  before do
    Geocoder.configure(lookup: :test, ip_lookup: :test)
    Geocoder::Lookup::Test.add_stub("foo", [])

    Geocoder::Lookup::Test.add_stub(
      "New York, NY", [
        {
          "coordinates" => [40.7143528, -74.0059731],
          "address" => "New York, NY, USA",
          "state" => "New York",
          "state_code" => "NY",
          "country" => "United States",
          "country_code" => "us",
          "postal_code" => "10001"
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "Bronx", [
        {
          "coordinates" => [40.8466508, -73.8785937],
          "address" => "The Bronx, New York, NY, USA",
          "state" => "New York",
          "state_code" => "NY",
          "country" => "United States",
          "country_code" => "us",
          "postal_code" => "10451"
        },
        {
          "coordinates" => [40.7143528, -74.0059731],
          "address" => "New York, NY, USA",
          "state" => "New York",
          "state_code" => "NY",
          "country" => "United States",
          "country_code" => "us",
          "postal_code" => "10001"
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "foobar", [
        {
          "coordinates" => [33.4860311, 126.4907944],
          "address" => "Jeju, South Korea",
          "state" => "Jeju",
          "state_code" => "49",
          "country" => "South Korea",
          "country_code" => "kr",
          "postal_code" => "63123"
        },
        {
          "coordinates" => [40.8466508, -73.8785937],
          "address" => "The Bronx, New York, NY, USA",
          "state" => "New York",
          "state_code" => "NY",
          "country" => "United States",
          "country_code" => "us",
          "postal_code" => "10451"
        }
      ]
    )

    Geocoder::Lookup::Test.add_stub(
      "London", [
        {
          "coordinates" => [51.5074456, -0.1277653],
          "address" => "London, Greater London, England, United Kingdom",
          "state" => "England",
          "state_code" => "EN",
          "country" => "United Kingdom",
          "country_code" => "gb",
          "postal_code" => nil
        },
        {
          "coordinates" => [42.9832406, -81.243372],
          "address" => "London, Ontario, N6A 3N7, Canada",
          "state" => "Ontario",
          "state_code" => "ON",
          "country" => "Canada",
          "country_code" => "ca",
          "postal_code" => "N6A 3N7"
        }
      ]
    )
  end

  it { is_expected.to have_attributes(geocoder: respond_to(:search), prefer_country_code: "us") }

  describe ".call" do
    subject(:result) { described_class.call("foo") }

    let(:stub) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(stub)
      allow(stub).to receive(:call)
    end

    it "is expected to create a new instance of the class" do
      result

      expect(described_class).to have_received(:new)
    end

    it "is expected to call the #call method on the new instance and forward arguments" do
      result

      expect(stub).to have_received(:call).with("foo")
    end
  end

  describe "#call" do
    subject(:result) { instance.call(address) }

    let(:address) { "New York, NY" }

    it { is_expected.to have_attributes(latitude: 40.7143528, longitude: -74.0059731, postal_code: "10001") }

    context "when multiple results are returned" do
      let(:address) { "Bronx" }

      it "is expected to return the first result" do
        expect(result).to have_attributes(latitude: 40.8466508, longitude: -73.8785937, postal_code: "10451")
      end

      context "when the first result is from a non-preferred country_code" do
        let(:address) { "foobar" }

        it "is expected to return the first result with a preferred country_code" do
          expect(result).to have_attributes(latitude: 40.8466508, longitude: -73.8785937, postal_code: "10451")
        end
      end

      context "when all results are from a non-preferred country_code" do
        let(:address) { "London" }

        it "is expected to return the first result" do
          expect(result).to have_attributes(latitude: 51.5074456, longitude: -0.1277653, postal_code: be_nil)
        end
      end
    end

    context "when no results are found" do
      let(:address) { "foo" }

      it { is_expected.to be_nil }
    end
  end
end
