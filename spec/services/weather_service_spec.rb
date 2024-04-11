require "rails_helper"

RSpec.describe WeatherService do
  subject(:instance) { described_class.new(weather:) }

  let(:weather) { instance_double(OpenWeather::Client) }

  it { is_expected.to have_attributes(weather:) }

  context "when weather client is not specified" do
    subject(:service) { described_class.new }

    it "is expected to fallback to OpenWeather::Client" do
      expect(service).to have_attributes(
        weather: a_kind_of(OpenWeather::Client).and(respond_to(:forecast))
      )
    end

    it "is expected to use the API key defined in Rails credentials" do
      expect(service).to have_attributes(
        weather: have_attributes(api_key: Rails.application.credentials.open_weather_api_key)
      )
    end
  end

  describe ".call" do
    subject(:result) { described_class.call(location) }

    let(:location) { instance_double("Location", latitude: 1, longitude: 2) }
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

      expect(stub).to have_received(:call).with(location)
    end
  end

  describe "#call" do
    subject(:result) { instance.call(location) }

    let(:location) { instance_double("Location", latitude: 1, longitude: 2, postal_code: "12345") }

    before do
      allow(weather).to receive(:forecast).with(1, 2, "12345").and_return(:foo)
    end

    it "is expected to call #forecast on the weather client with the latitude and longitude from the location" do
      result

      expect(weather).to have_received(:forecast).with(1, 2, "12345")
    end

    it "is expected to return the return value of weather#forecast" do
      expect(result).to be :foo
    end
  end
end
