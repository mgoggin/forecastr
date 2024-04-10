class ReadingsController < ApplicationController
  def new
  end

  def create
    @location = LocationService.call(reading_params[:address])

    if @location.blank?
      render partial: "readings/form", locals: { error: "Unable to lookup that location!" }

      return
    end

    @weather = WeatherService.call(@location)
  end

  private

  def reading_params
    params.require(:reading).permit(:address)
  end
end
