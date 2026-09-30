# frozen_string_literal: true

# Configures application-wide settings.
#
# Defaults defined in `config/app.yml`.
class AppConfig < BaseConfig
  config_name :app

  attr_config :base_url,
    :time_zone,
    :default_locale,
    :git_commit,
    :host, # deprecated
    :port, # deprecated
    title: I18n.t("layouts.application.application_title")

  on_load :ensure_base_url_is_present

  def default_url_options
    return if base_url.blank? # When recompiling assets.

    uri = URI.parse(base_url)
    url_options = { host: uri.host, protocol: uri.scheme }
    url_options[:port] = uri.port if uri.port != uri.default_port

    url_options
  end

  private

  def ensure_base_url_is_present
    self.base_url ||= if host.present?
      host_with_scheme
    else
      raise_validation_error("The following config parameter for `AppConfig(config_name: app)` is missing or empty: base_url") unless Anyway::Settings.suppress_required_validations
    end
  end

  def host_with_scheme
    warn("[DEPRECATION] `AppConfig` - The `host` and `port` options are deprecated and will be removed in a future version. Please use the `base_url` option instead.")

    uri = URI.parse(host)

    case uri.scheme
    when "http"
      URI::HTTP.build(host: uri.host, port:).to_s
    when "https"
      URI::HTTPS.build(host: uri.host, port:).to_s
    else
      URI::HTTPS.build(host:, port:).to_s
    end
  end
end
