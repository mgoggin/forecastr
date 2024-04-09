module OpenWeather
  Reading = Data.define(:current_conditions, :daily_forecast) do
    def self.from_api(payload)
      time_zone = payload[:timezone].presence || Time.zone_default.tzinfo.name

      Time.use_zone(time_zone) do
        current = payload[:current]
        daily = payload[:daily]

        current_conditions = CurrentConditions.from_api(current.slice(:dt, :temp))
        daily_forecast = Array.wrap(daily).map { DailyForecast.from_api(_1.slice(:temp, :dt, :summary)) }

        new(current_conditions:, daily_forecast:)
      end
    end
  end
end
