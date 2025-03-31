# frozen_string_literal: true

class AppConfig < BaseConfig
  config_name :app
  attr_config :host,
              port: 3000,
              title: I18n.t("layouts.application.application_title"),
              time_zone: "UTC",
              default_locale: :en

  required :host, env: %w[development production]

  def http_host
    if Rails.env.test?
      "http://example.com"
    elsif host.starts_with?("http://", "https://")
      host
    else
      "https://#{host}"
    end
  end
end
