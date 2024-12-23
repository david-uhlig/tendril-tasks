# frozen_string_literal: true

class AppConfig < BaseConfig
  config_name :app
  attr_config brand_badge: "Tendril Tasks",
              title: I18n.t("layouts.application.application_title"),
              time_zone: "UTC",
              default_locale: :en
end
