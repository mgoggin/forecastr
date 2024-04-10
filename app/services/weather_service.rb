# Retrieve the current weather conditions and the extended weather forecast for a given [Location].
#
# The weather client can be specified when the service is instantiated. This may be useful if you want to instantiate
# a client with a different API key, or if you want to use a different client altogether. The client can be any object
# that responds to +#forecast+. Be default, it uses +OpenWeather::Client+ with the API key defined in Rails credentials.
class WeatherService
  # @!attribute [r] weather
  #   @return [#forecast] the weather client used to fetch current conditions and the extended forecast
  attr_reader :weather

  # Retrieve the current weather conditions and extended forecast for the given [Location] using the default client.
  #
  # @see [#call]
  def self.call(*)
    new.call(*)
  end

  # Create a new instance of the service.
  #
  # If +weather+ is not specified, the value will default to +nil+ and will fallback to using [OpenWeather::Client] with
  # the API key defined in Rails credentials with key +open_weather_api_key+.
  #
  # @param weather [#forecast|nil] the weather client to use to get a weather reading; defaults to +nil+
  # @return self
  def initialize(weather: nil)
    @weather = weather || OpenWeather::Client.new(api_key: Rails.application.credentials.open_weather_api_key)
  end

  # Retrieve the current weather conditions and extended forecast for the given [Location].
  #
  # @param location [Location] the location for which to retrieve the weather reading
  # @return [OpenWeather::Reading] the weather reading containing current conditions and extended forecast for the
  #   [Location].
  def call(location)
    weather.forecast(location.latitude, location.longitude)
  end
end
