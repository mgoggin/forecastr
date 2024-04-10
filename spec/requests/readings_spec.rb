require "rails_helper"

RSpec.describe "Readings", type: :request do
  describe "GET /" do
    it "is expected to return HTTP success" do
      get "/readings/new"

      expect(response).to have_http_status(:success)
    end

    it "is expected to render the new template" do
      get "/readings/new"

      expect(response).to render_template("readings/new")
    end
  end

  describe "GET /create" do
    let(:location) { instance_double("Location", latitude: 1, longitude: 2, postal_code: "12345") }

    let(:weather) do
      instance_double(
        "OpenWeather::Reading",
        current_conditions: instance_double("OpenWeather::CurrentConditions", temperature: 72.32),
        daily_forecast: [],
        cached: false
      )
    end

    before do
      allow(LocationService).to receive(:call).with("test").and_return(location)
      allow(WeatherService).to receive(:call).with(location).and_return(weather)
    end

    it "is expected to return HTTP success" do
      post "/readings", params: { reading: { address: "test" } }

      expect(response).to have_http_status(:success)
    end

    it "is expected to render the create template" do
      post "/readings", params: { reading: { address: "test" } }

      expect(response).to render_template("readings/create")
    end

    it "is expected to assign the location to the view" do
      post "/readings", params: { reading: { address: "test" } }

      expect(assigns(:location)).to eq location
    end

    it "is expected to assign the weather to the view" do
      post "/readings", params: { reading: { address: "test" } }

      expect(assigns(:weather)).to eq weather
    end

    context "when the location lookup fails", :aggregate_failures do
      let(:location) { nil }

      it "is expected to render the form partial with an alert" do
        post "/readings", params: { reading: { address: "test" } }

        expect(response).to render_template(partial: "readings/_form")
        expect(response).to render_template(partial: "application/_alert")
      end
    end
  end
end
