source "https://rubygems.org"

ruby "3.4.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"

# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
gem "tailwindcss-rails", "~> 4.0"

gem "pg"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Hotwire"s SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [ :windows, :jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

gem "activeadmin", "~> 3.3.0"
gem "brakeman"
gem "data_migrate"
gem "devise"
gem "friendly_id", "~> 5.5.0"
gem "hashid-rails", "~> 1.0"
gem "json_schemer"
gem "pundit"

gem "sidekiq"
gem "sidekiq-scheduler"
gem "sidekiq-unique-jobs"

gem "positioning"
gem "strong_migrations"

# Validations
gem "validate_url"
gem "valid_email2"

gem "kaminari", "~> 1.1"
gem "responders", "~> 3.0"

# Payments
gem "money-rails"
gem "stripe"
gem "stripe_event"

gem "addressable"
gem "faraday"
gem "faraday-follow_redirects"
gem "faraday-multipart"

gem "paper_trail"
gem "sentry-rails"
gem "sentry-ruby"

gem "web-push"

group :development, :test do
  gem "annotaterb"
  gem "better_errors"
  gem "binding_of_caller"
  gem "bullet"
  gem "debug", platforms: [ :mri, :windows ]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "foreman"
  gem "leftovers"
  gem "letter_opener"
  gem "rspec-rails"
  gem "rubocop", ">= 1.74.0", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", "!= 2.29.0", require: false
  gem "webmock"
end

group :development do
  gem "rubocop-rails-omakase"
  gem "dockerfile-rails", ">= 1.7"
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "database_cleaner-active_record"
end

gem "aws-sdk-s3", "~> 1.178", require: false
