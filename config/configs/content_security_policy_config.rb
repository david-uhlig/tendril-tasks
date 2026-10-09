# frozen_string_literal: true

require "uri"

# Configures and extends the base policy without duplicating it.
#
# Directives are configurable via `config.x.content_security_policy` settings,
# Rails credentials under `content_security_policy`, and `CSP_` ENV-vars, in
# increasing order of precedence. This allows deployments to extend the base
# policy without duplicating it.
#
# config.x.content_security_policy.* and credentials (string, space-separated string, or array):
#   default_src, script_src, style_src, connect_src, frame_src, img_src, font_src, media_src,
#   worker_src, frame_ancestors, form_action, report_uri, report_only, disabled
#
# ENV vars (space-separated sources):
#   CSP_DEFAULT_SRC, CSP_SCRIPT_SRC, CSP_STYLE_SRC, CSP_CONNECT_SRC, CSP_FRAME_SRC,
#   CSP_IMG_SRC, CSP_FONT_SRC, CSP_MEDIA_SRC, CSP_WORKER_SRC, CSP_FRAME_ANCESTORS,
#   CSP_FORM_ACTION, CSP_REPORT_URI, CSP_REPORT_ONLY, CSP_DISABLED
class ContentSecurityPolicyConfig < BaseConfig
  config_name :content_security_policy
  # Extends the base policy via `config.x.content_security_policy`.
  loader_options rails_config_x: true
  # Accepts ENV variables with the prefix `CSP_`, e.g. `CSP_DEFAULT_SRC`.
  env_prefix :csp

  attr_config :default_src,
    :script_src,
    :connect_src,
    :frame_src,
    :style_src,
    :img_src,
    :font_src,
    :media_src,
    :worker_src,
    :form_action,
    :frame_ancestors,
    :report_uri,
    report_only: false,
    disabled: false

  coerce_types default_src: { type: :string, array: true },
    script_src: { type: :string, array: true },
    connect_src: { type: :string, array: true },
    frame_src: { type: :string, array: true },
    style_src: { type: :string, array: true },
    img_src: { type: :string, array: true },
    font_src: { type: :string, array: true },
    media_src: { type: :string, array: true },
    worker_src: { type: :string, array: true },
    form_action: { type: :string, array: true },
    frame_ancestors: { type: :string, array: true },
    report_uri: :string

  def sources(directive)
    value = send(directive)

    case value
    when nil then []
    when Array then value.flat_map(&:split)
    when String then value.split
    else []
    end
  end

  def enabled?
    !disabled?
  end

  def report_uri?
    !report_uri.nil? && !report_uri.empty?
  end

  def validated_report_uri
    value = report_uri
    return nil if value.nil? || value.empty?

    uri = URI.parse(value)
    valid_location = (uri.is_a?(URI::HTTPS) && uri.host && !uri.userinfo) ||
                     (uri.is_a?(URI::Generic) && uri.host.nil? && value.start_with?("/") &&
                       !value.start_with?("//"))
    valid_syntax = !value.match?(/[[:cntrl:][:space:];]/) && uri.fragment.nil?

    raise ArgumentError, "CSP_REPORT_URI must be an HTTPS URL or same-origin path" unless valid_location && valid_syntax

    value
  rescue URI::InvalidURIError
    raise ArgumentError, "CSP_REPORT_URI must be an HTTPS URL or same-origin path"
  end
end
