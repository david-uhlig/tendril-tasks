source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Authentication through Devise and Omniauth
gem "devise"
gem "omniauth"
gem "omniauth-rails_csrf_protection"
gem "omniauth-rocketchat"

# TailwindCSS framework
gem "tailwindcss-rails", "~> 3.3.1"
gem "tailwind_merge", "~> 0.14"

# Create reusable, testable & encapsulated view components
# See https://viewcomponent.org/
gem "view_component", "~> 3.18"

# Authorization
gem "cancancan"

# Configuration
gem "anyway_config", "~> 2.0"
gem "dotenv-rails"

# Add support for inline SVGs
gem "inline_svg"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Active Storage validations
gem "active_storage_validations", "~> 2.0"

# Notifications
gem "noticed", "~> 2.6"

# ActiveJob Dashboard [https://github.com/rails/mission_control-jobs]
gem "mission_control-jobs"
# ActiveStorage Dashboard [https://github.com/giovapanasiti/active_storage_dashboard]
gem "active_storage_dashboard"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing framework
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails"
  gem "simplecov"
  gem "capybara"
  gem "selenium-webdriver"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Help to kill N+1 queries and unused eager loading [https://github.com/flyerhzm/bullet]
  gem "bullet"
  # Hot reloading
  gem "hotwire-spark"
end
