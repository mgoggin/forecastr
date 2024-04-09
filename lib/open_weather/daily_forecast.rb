module OpenWeather
  DailyForecast = Data.define(:temperature, :forecasted_for, :summary) do
    def self.from_api(payload)
      temperature = payload.dig(:temp, :day).presence
      forecasted_for = payload[:dt].presence
      summary = payload[:summary].presence

      unless forecasted_for.present? && forecasted_for.to_s.match?(/^\d+$/)
        raise ArgumentError, ":forecasted_for must be a UNIX timestamp"
      end

      forecasted_for = Time.zone.at(forecasted_for)

      new(
        temperature:,
        forecasted_for:,
        summary:
      )
    end
  end
end
