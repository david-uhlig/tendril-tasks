# Autoload all components in the app/components/gustwave directory
#
# This is required to make the themable concern work because components
# need to register themselves before they can be used as themes.
Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/components/gustwave/**/*.rb")].each do |file|
    require_dependency file
  end
end
