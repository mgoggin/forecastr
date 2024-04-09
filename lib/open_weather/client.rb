require "faraday"

module OpenWeather
  class Client
    attr_reader :api_key

    def initialize(api_key:)
      @api_key = api_key
    end

    def forecast(latitude, longitude)
      response = connection.get("/data/3.0/onecall") do |request|
        request.params["lat"] = latitude
        request.params["lon"] = longitude
      end

      params = ActionController::Parameters
        .new(response.body)
        .permit(
          :timezone,
          current: [:temp, :dt],
          daily: [:dt, :summary, { temp: :day }]
        )

      Reading.from_api(params)
    end

    private

    def connection
      @_connection ||= Faraday.new(
        params: {
          appid: api_key,
          exclude: "minutely,hourly,alerts",
          units: "imperial"
        },
        url: "https://api.openweathermap.org"
      ) do |builder|
        builder.request :json, encoder: Oj
        builder.response :json, parser_options: { decoder: Oj }
        builder.response :raise_error
      end
    end
  end
end
