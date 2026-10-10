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
    :title,
    # Seconds the confirm button of delete confirmation modals stays disabled
    # after the modal is shown, to prevent accidental deletions.
    delete_confirm_cooldown: 3

  coerce_types delete_confirm_cooldown: :integer

  on_load :ensure_base_url_is_present

  def title
    @title ||= super || I18n.t("layouts.application.application_title")
  end

  def default_url_options
    return if base_url.blank? # When recompiling assets.

    uri = URI.parse(base_url)
    url_options = { host: uri.host, protocol: uri.scheme }
    url_options[:port] = uri.port if uri.port != uri.default_port

    url_options
  end

  # In development, falls back to the checked out commit, so it doesn't need to
  # be configured. In production it is set during deployment.
  def git_commit
    super.presence || (local_git_commit if Rails.env.development?)
  end

  private

  # Memoized, including a missing commit, so git isn't run again on every call.
  def local_git_commit
    return @local_git_commit if defined?(@local_git_commit)

    @local_git_commit = begin
      commit = IO.popen(%w[git rev-parse --short HEAD], chdir: Rails.root, err: File::NULL, &:read)
      commit.strip.presence if $?.success?
    rescue SystemCallError
      nil
    end
  end

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
