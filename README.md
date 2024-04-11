# Forecastr
A demo application to retrieve the weather for a given location.

## Setup
This application uses *Rails 7.1, Ruby 3.3, and Redis*. You'll need to have Ruby 3.3 and Redis installed on your machine to boot the app locally.

By default, the application will look for Redis on localhost:6379.

### Get it
Clone to repo to your machine and run:
```console
$ bundle
```

### Run it
#### `RAILS_MASTER_KEY`

**Before running the app for the first time, you'll need to ensure that you have `RAILS_MASTER_KEY` set in your environment.** 

I recommend exporting the variable locally using `export RAILS_MASTER_KEY=masterkeygoeshere`. If you use direnv, you can also place that command in a .envrc file in the root of the project and `direnv allow`.

You can always just prefix all your commands with it like `RAILS_MASTER_KEY=masterkeygoeshere rails s`.

**I will have sent you the master key by email.**

#### Tests
To run the test suite:
```console
$ bin/rails spec
```

To run the test suite and update the VCR cassettes:
```console
$ VCR=1 bin/rails spec
```

#### Server
To start the app, run:
```console
$ rails dev:cache
$ bin/dev
```

The `rails dev:cache` command will enable caching in development using the in-memory cache store.

Once the app is running, you can visit https://127.0.0.1:3000 in browser.

### Generated using
This application was generated using the following:
```console
$ rails new forecastr \
  --skip-action-mailer \
  --skip-action-mailbox \
  --skip-action-text \
  --skip-active-storage \
  --skip-jbuilder \
  --skip-test \
  --skip-system-test \
  -a propshaft \
  -c tailwind
```

I removed anything I knew I wasn't going to use. You might notice `--skip-test` and `--skip-system-test`. I prefer RSpec so I didn't want Rails to generate boilerplate with Minitest only to delete it later.

## Docs

I didn't go nuts writing inline comments with the code. Code should be self-documenting in most cases and I hope I managed to achieve that here. Still, you'll notice that most of the code is documented using YARD. I prefer writing YARD docs since most IDEs will pick that up to provide code hinting.

## Flow

The flow for the application is fairly straightforward: the user is presented with a text field on the page into which they can type an address or some other geocodable string. When they submit the form on the page, the application will perform a geocoding lookup using the geocoder gem to get the coordinates of the location they entered. Once we have the coordinates, we'll call the Open Weather API with those coordinates to get the current weather conditions and the extended forecast. This information from the API is captured in several domain objects to make working with them a little easier. The location and the weather information is passed to the view layer which will render the weather information for that location.

## Caching

Weather lookup as cached by postal code. If a geocoding lookup doesn't return a postal code, we do not cache the result. If a cached result is returned to the user, the view will note that the weather information being displayed comes from the cache.

The cache expires after 30 minutes.

`ActiveSupport::Cache` was used as the caching mechanism over creating database records with ActiveRecord. The data isn't really relational and there was no requirement to persist it in that manner so I opted to use simple key-value cache.

The caching happens in the weather client. I considered moving it up the controller, but I wanted to cache the raw API response rather than the serialized domain objects. This should prevent issues with the serialized objects in the cache no longer matching the implementation of those objects if the code changes.

## Domain Objects

There are a number of domain objects in use within the application.

* app/models/location.rb (`Location`)

  This object represents a specific location on Earth. It stores the `latitude`, `longitude`, and `postal_code` of the location returned by the geocoder.

  It's a model, just not a database-backed model. It wasn't written to be part of a larger module like the other domain objects on this list.

* lib/open_weather/current_conditions.rb (`OpenWeather::CurrentConditions`)

  This object represents the current weather conditions for a given location. It stores the `temperature` and the `recorded_at` datetime from the weather API. It lives inside the `OpenWeather` module since that's where it's most likely to be used.

* lib/open_weather/daily_forecast.rb (`OpenWeather::DailyForecast`)

  This object represents the extended forecast for a given location. It stores the `temperature`, `forecasted_for` datetime, and a `summary` of the weather conditions for that day.

* lib/open_weather/temperature.rb (`OpenWeather::Temperature`)

  This object represents a temperature reading. It stores the `current` temp, as well as the `high` and `low`. `current` is required, but `high` and `low` are optional.

* lib/open_weather/reading.rb (`OpenWeather::Reading`)

  This object represents a weather reading. It stores the `current_conditions` and `daily_forecast`. It also stores whether the data being presented was `cached` or not. The Open Weather API returns datetimes as UNIX timestamps. When converting those to `TimeWithZone` instances using `Time.zone.at`, we wrap our code in a `Time.use_zone` block to ensure that those datetimes are created in the correct timezone.

## Services

There are two service objects that handle the interaction with both APIs (defined below): `LocationService` and `WeatherService`.

Both service objects respond to `.call` and `#call`.

`LocationService` will perform a lookup for the provided string and will return a `Location` if a location could be geocoded.

`WeatherService` will retrieve the current weather conditions and the extended forecast for a given `Location` and will return an `OpenWeather::Reading`. In hindsight, `Reading` might have been better as a domain object in app/models.

## API Usage

### Geocoding

I've made use of the geocoder gem which supports many backends. The one I'm using is the Nominatim backend, which is free for limited usage. Since this gem supports many different backends, in theory it should be possible to swap these out with minimal change to the geocoder implementation.

### Weather

I chose the Open Weather API because it offered most of what I needed for free. There is an open_weather_sdk gem, but it seems unmaintained and it didn't offer access to the OneCall 3.0 API, which is what I wanted to use. So I built my own client (`OpenWeather::Client`). The API key can be passed in when the client is instantiated. If one is not provided, it will use the key at `Rails.application.credentials.open_weather_api_key`.

## Testing

RSpec is my preferred test framework. There should be 100% unit coverage.

### VCR vs direct stubs

I opted to use VCR to record interaction with the weather API. I wanted the specs to have "real" data to test against and didn't want to stub out fake responses that just _looked_ like they were real.

You'll notice, however, that I **did not** use VCR for the interaction with the Nominatim API (used for geocoding). That's because I wrote that before I wrote the weather retrieval code and wasn't using VCR at that point. I considered rewriting those specs, but decided to leave them to showcase both approaches. For simple APIs, I generally prefer directly mocking responses so I can be absolutely sure what data is being passed around, but for more complicated APIs, or APIs with larger payloads, VCR can come in handy as a "set it and forget it" tool.
