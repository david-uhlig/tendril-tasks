# Be sure to restart your server when you modify this file.

# Define an application-wide Content Security Policy.
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
#
# Adapted from https://github.com/basecamp/fizzy/blob/477c943e0506f109e5bc83ae9dadbe519732c045/config/initializers/content_security_policy.rb
CSP = ContentSecurityPolicyConfig.new

Rails.application.configure do
  # Generate nonces for importmap and inline scripts.
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[ script-src ]

  config.content_security_policy do |policy|
    policy.default_src :self, *CSP.sources(:default_src)
    policy.script_src :self, *CSP.sources(:script_src)
    policy.connect_src :self, *CSP.sources(:connect_src)
    policy.frame_src :self, *CSP.sources(:frame_src)

    # Don't fight user tools: permit inline styles, data:/https: sources, and
    # blob: workers for accessibility extensions, privacy tools, and custom fonts.
    policy.style_src :self, :unsafe_inline, *CSP.sources(:style_src)
    policy.img_src :self, "blob:", "data:", "https:", *CSP.sources(:img_src)
    policy.font_src :self, "data:", "https:", *CSP.sources(:font_src)
    policy.media_src :self, "blob:", "data:", "https:", *CSP.sources(:media_src)
    policy.worker_src :self, "blob:", *CSP.sources(:worker_src)

    # Security-critical defaults (not configurable)
    policy.object_src :none
    policy.base_uri :none

    policy.form_action :self, *CSP.sources(:form_action)
    policy.frame_ancestors :self, *CSP.sources(:frame_ancestors)

    # Specify URI for violation reports
    # Deprecated, see: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/report-uri
    # Replace with `report_to` when Rails supports it,
    # i.e. https://github.com/rails/rails/pull/52367 or similar lands.
    policy.report_uri CSP.validated_report_uri if CSP.report_uri?
  end

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = CSP.report_only?

  # Locked-down policy for the static pages served from public/ (error pages).
  # They carry no script or inline styles at all, so everything falls back to
  # default-src 'none'.
  static_policy = "default-src 'none'; img-src 'self'; style-src 'self'; " \
    "base-uri 'none'; form-action 'none'; frame-ancestors 'none'"

  # Report violations from the static pages to the same collector as the
  # app policy, so a report-only rollout sees them too.
  static_policy += "; report-uri #{CSP.validated_report_uri}" if CSP.report_uri?

  # Honor report-only mode for the static policy too, so the report_only
  # switch disables enforcement everywhere at once.
  static_policy_header = CSP.report_only ? ActionDispatch::Constants::CONTENT_SECURITY_POLICY_REPORT_ONLY \
    : ActionDispatch::Constants::CONTENT_SECURITY_POLICY

  # Files served straight from public/ return before the CSP middleware runs,
  # so they get the static policy stamped by the file server.
  config.public_file_server.headers = (config.public_file_server.headers || {}) \
    .merge(static_policy_header => static_policy)

  # The same public/ pages served through the error path (a real 404/500
  # renders public/404.html via the exceptions app, bypassing the static
  # file server) get it too. JSON error responses pass through untouched.
  # A deployment that configures its own exceptions_app keeps full control
  # of its responses, headers included.
  if config.exceptions_app.nil?
    public_exceptions = ActionDispatch::PublicExceptions.new(Rails.public_path)
    config.exceptions_app = ->(env) do
      public_exceptions.call(env).tap do |_status, headers, _body|
        if headers[Rack::CONTENT_TYPE].to_s.start_with?("text/html")
          headers[static_policy_header] = static_policy
        end
      end
    end
  end

  # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
  # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
  config.content_security_policy_nonce_auto = true
end unless CSP.disabled?

# https://github.com/giovapanasiti/active_storage_dashboard/issues/16
unless CSP.disabled?
  Rails.application.config.to_prepare do
    # This controller-only policy copies the global policy and replaces script-src.
    ActiveStorageDashboard::ApplicationController.content_security_policy do |policy|
      policy.script_src :self,
        *CSP.sources(:script_src),
        "sha256-2BUHmQWRFzQhqEjInUsQ3jVxdmQ+TOG07uS9GIz2YHA=",
        "sha256-SU+rQGPZ43y5HuPKqGnqHIcAM6iX3mKrGGSov3meP5E=",
        "sha256-f0bJ3QDUI/dH3agnHablQzrFfUr9kcod2mSyUq4mPbo=",
        "sha256-qfXqarG2yzgBvO6ow3xVduq6ns4dBMzaSnwhclggdZk="
    end
  end
end
