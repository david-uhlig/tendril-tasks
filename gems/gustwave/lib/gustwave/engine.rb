# frozen_string_literal: true

module Gustwave
  # Rails engine that loads Gustwave into the host app when the gem is required. It
  # reads +config.gustwave+, registers Gustwave.deprecator with the app's deprecators,
  # and adds the gem's JavaScript to the asset and importmap paths.
  class Engine < ::Rails::Engine
    engine_name "gustwave"

    config.gustwave = ActiveSupport::OrderedOptions.new

    # See Gustwave.strict?
    initializer "gustwave.strict" do |app|
      Gustwave.strict = app.config.gustwave.strict
    end

    # See Gustwave.deprecator
    initializer "gustwave.deprecator" do |app|
      app.deprecators[:gustwave] = Gustwave.deprecator
    end

    # Serve the Stimulus controllers in app/javascript/controllers/gustwave.
    # Apps that eager load their controllers from "controllers" register them
    # as +gustwave--*+, e.g. +gustwave--lexxy-heading+.
    initializer "gustwave.assets" do |app|
      app.config.assets.paths << root.join("app/javascript") if app.config.respond_to?(:assets)
    end

    initializer "gustwave.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end
  end
end
