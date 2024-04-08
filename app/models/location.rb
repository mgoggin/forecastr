# A location on Earth.
Location = Data.define(:latitude, :longitude, :postal_code) do
  # Coordinates of the location.
  #
  # @return String|nil latitude and longitude, if present, separated by a comma
  def coordinates
    raise ":latitude and :longitude must both be provided" if latitude.blank? || longitude.blank?

    [latitude, longitude].compact.presence&.join(", ")
  end
end
