source "https://rubygems.org"

ruby "3.3.0"

# Framework
gem "rails", "~> 7.1.3", ">= 7.1.3.2"

# Drivers
gem "redis", ">= 4.0.1"
gem "sqlite3", "~> 1.4"

# Asset/View Extensions
gem "importmap-rails"
gem "propshaft"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"

# Application Server
gem "puma", ">= 5.0"

# Utilities
gem "bootsnap", require: false
gem "faraday"
gem "geocoder"
gem "oj", "~> 3.16"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.3"
  gem "rspec-rails", "~> 6.1"
  gem "rubocop-thread_safety"
  gem "standard"
  gem "standard-rails"
end

group :development do
  gem "boring_generators"
  gem "bundler-audit", require: false
  gem "guard-rspec", require: false
  gem "ruby_audit", require: false
  gem "web-console"
end

group :test do
  gem "rails-controller-testing", "~> 1.0"
  gem "simplecov", require: false
  gem "timecop", "~> 0.9.8"
  gem "vcr", "~> 6.2"
  gem "webmock", "~> 3.23"
end
