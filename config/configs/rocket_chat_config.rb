# frozen_string_literal: true

# Configures Rocket.Chat OmniAuth OAuth2 access via Rocket.Chat's third-party
# provider feature.
class RocketChatConfig < BaseConfig
  config_name :rocket_chat
  attr_config :host,
              :client_id,
              :client_secret,
              authorize_url: "/oauth/authorize",
              token_url: "/oauth/token",
              branding: "Rocket.Chat",
              pkce: false

  # Optional in development, where users can sign in through the development
  # sign in instead.
  required :host, :client_id, :client_secret, env: "production"

  # Returns whether the OAuth login was configured.
  #
  # @return [Boolean]
  def configured?
    [ host, client_id, client_secret ].all?(&:present?)
  end

  # Returns the workspace URL, e.g. "https://chat.example.com". Adds `https://`
  # when the host was configured without a scheme.
  def host
    value = super
    return value if value.blank?

    value = value.delete_suffix("/")
    value.match?(%r{\Ahttps?://}i) ? value : "https://#{value}"
  end
end
