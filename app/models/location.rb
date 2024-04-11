# A location on Earth.
#
# This is a value object that holds the latitude, longitude, and postal code for a specific location. The values for
# these attributes will come from whatever geocoding service is being used.
#
# @example
#   location = Location.new(latitude: 123.00000, longitude: -80.98765, postal_code: "12345")
#
# @param latitude [String|Numeric]
# @param longitude [String|Numeric]
# @param postal_code [String]
# @return self
Location = Data.define(:latitude, :longitude, :postal_code)
