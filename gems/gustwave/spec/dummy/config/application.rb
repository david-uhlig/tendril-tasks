# frozen_string_literal: true

require "rails"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_text/engine"
require "propshaft"
require "gustwave"

module Dummy
  # Minimal host application to run Gustwave's specs against. Action Text is
  # optional for Gustwave, but Gustwave::RichText renders its content.
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.root = File.expand_path("..", __dir__)
    config.eager_load = false
    config.secret_key_base = "dummy"
    config.logger = Logger.new(nil)
    config.active_storage.service = :test
    config.i18n.available_locales = %i[en de]
    config.i18n.default_locale = :en
  end
end
