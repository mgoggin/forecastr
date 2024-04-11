module OpenWeather
  CurrentConditions = Data.define(:temperature, :recorded_at) do
    def self.from_api(payload)
      temperature = payload[:temp].presence
      recorded_at = payload[:dt].presence

      unless recorded_at.present? && recorded_at.to_s.match?(/^\d+$/)
        raise ArgumentError, ":recorded_at must be a UNIX timestamp"
      end

      recorded_at = Time.zone.at(recorded_at)

      new(
        temperature:,
        recorded_at:
      )
    end
  end
end
