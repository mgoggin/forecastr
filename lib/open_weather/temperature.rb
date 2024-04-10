module OpenWeather
  Temperature = Data.define(:current, :high, :low) do
    def self.from_api(payload)
      current = payload&.dig(:day).presence

      if current.blank?
        raise ArgumentError, ":current must be provided"
      end

      high = payload&.dig(:max).presence
      low = payload&.dig(:min).presence

      new(current:, high:, low:)
    end
  end
end
