# Component explorer for Gustwave's previews. The gem isn't installed in
# production, see the Gemfile.
if defined?(Lookbook)
  require Gustwave::Engine.root.join("lookbook/flowbite_coverage")

  Rails.application.configure do
    config.lookbook.project_name = "Gustwave"
    config.lookbook.preview_display_options = { theme: %w[light dark] }
    config.lookbook.listen_paths << Gustwave::Engine.root.join("app/components").to_s
    config.lookbook.page_paths = [ Gustwave::Engine.root.join("lookbook/pages").to_s ]
    config.lookbook.page_nav_filter = true
  end

  # Lists the Flowbite examples a scenario reproduces.
  Lookbook.add_panel(:flowbite, "lookbook/panels/flowbite",
                     label: "Flowbite",
                     disabled: ->(data) { Gustwave::FlowbiteCoverage.current.for_scenario(data.target.lookup_path).empty? })
end
