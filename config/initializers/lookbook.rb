# Component explorer for Gustwave's previews. The gem isn't installed in
# production, see the Gemfile.
if defined?(Lookbook)
  Rails.application.configure do
    config.lookbook.project_name = "Gustwave"
    config.lookbook.preview_display_options = { theme: %w[light dark] }
    config.lookbook.listen_paths << Gustwave::Engine.root.join("app/components").to_s
  end
end
