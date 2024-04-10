require "faraday"

module OpenWeather
  class Client
    attr_reader :api_key

    def initialize(api_key:)
      @api_key = api_key
    end

    def forecast(latitude, longitude, postal_code = nil)
      body, cached = with_cache(postal_code) do
        response = connection.get("/data/3.0/onecall") do |request|
          request.params["lat"] = latitude
          request.params["lon"] = longitude
        end

        response.body
      end

      params = ActionController::Parameters
        .new(body)
        .permit(
          :timezone,
          current: [:temp, :dt],
          daily: [:dt, :summary, { temp: :day }]
        )

      Reading.from_api(params, cached:)
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

    def with_cache(key, &block)
      return yield if key.blank?
      return [Rails.cache.read(cache_key_for(key)), true] if Rails.cache.exist?(cache_key_for(key))

      value = block.call

      Rails.cache.write(cache_key_for(key), value, expires_in: 30.minutes)

      [value, false]
    end

    def cache_key_for(key)
      [:open_weather, :api, key].join("-")
    end
  end
end
