# Lookup an address using a geocoder.
#
# The geocoder can be specified when the service is instantiated. This can be any class or instance that responds to
# +#search+. By default it uses the geocoder gem, which supports many different geocoding backends.
class LocationService
  # !@attribute [r] geocoder
  #   @return [#search] the geocoder instance used to perform the lookup
  attr_reader :geocoder

  # !@attribute [r] prefer_country_code
  #   @return String the country code to prefer when ordering results
  attr_reader :prefer_country_code

  # Lookup an address using the default geocoder and preferred country code.
  #
  # @see [#call]
  def self.call(*)
    new.call(*)
  end

  # Create an instance of the service.
  #
  # @param geocoder [#search] the geocoder instance to use to perform the lookup
  # @param prefer_country_code String the country code to prefer when ordering result; defaults to "us"
  # @return self
  def initialize(geocoder: Geocoder, prefer_country_code: "us")
    @geocoder = geocoder
    @prefer_country_code = prefer_country_code
  end

  # Lookup an address.
  #
  # If :prefer_country_code is set then results will be ordered so locations that match the given code will be preferred
  # over those that do not.
  #
  # Regardless of how many results are returned, only the first result will be used.
  #
  # @param query String the address to lookup
  # @return [Location|nil] the Location that contains the latitude, longitude, and postal code of the top result
  def call(query)
    results = geocoder.search(query)
    result = results.find { _1.country_code == prefer_country_code } if prefer_country_code.present?
    result ||= results.first

    return if result.blank?

    Location.new(latitude: result.latitude, longitude: result.longitude, postal_code: result.postal_code)
  end
end
