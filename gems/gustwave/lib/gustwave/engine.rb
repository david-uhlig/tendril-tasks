# frozen_string_literal: true

module Gustwave
  class Engine < ::Rails::Engine
    engine_name "gustwave"

    # Themes register themselves at their subject class when they are loaded,
    # see Gustwave::Themeable. Load all components up front, so that every
    # theme is registered before the first render.
    config.to_prepare do
      Rails.autoloaders.main.eager_load_dir(Gustwave::Engine.root.join("app/components/gustwave"))
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
