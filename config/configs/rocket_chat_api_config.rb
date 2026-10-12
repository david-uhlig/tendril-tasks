# frozen_string_literal: true

# Configures Rocket Chat (RC) API access.
#
# Most commonly used for sending messages.
class RocketChatApiConfig < BaseConfig
  config_name :rocket_chat_api

  # RC workspace URL, e.g. `chat.example.com`. Use the `url` method to receive a well-formed url
  # including a scheme, host, and api_path.
  attr_config :host
  # RC api path, e.g. `/api/v1`.
  attr_config path: "/api/v1"
  # RC API authentication token and user id.
  #
  # Obtain by generating a personal access token (PAT) in RC for the user accessing the API, e.g. at https://<your-rocket-chat-workspace.com>/account/tokens after signing in.
  attr_config :auth_token, :user_id

  # Returns the workspace URL, e.g. "https://example.com". Adds `https://` when
  # the host was configured without a scheme.
  def host
    value = super
    return value if value.blank?

    value = value.delete_suffix("/")
    value.match?(%r{\Ahttps?://}i) ? value : "https://#{value}"
  end

  # Returns the api URL, e.g. "https://example.com/api/v1"
  def url
    "#{host}#{path}"
  end

  # Returns the authentication headers required for most RC API endpoints.
  #
  # @return [Hash] Authentication header for API requests.
  def auth_headers
    {
      "X-Auth-Token": auth_token,
      "X-User-Id": user_id
    }
  end

  # Returns the authentication cookies for requests to the workspace outside
  # the API, e.g. for avatars when Rocket.Chat blocks unauthenticated access to
  # them.
  #
  # @return [String, nil] Cookie header, or nil when API access isn't configured.
  def auth_cookie
    return unless configured?

    "rc_uid=#{user_id}; rc_token=#{auth_token}"
  end

  # Returns whether the URI points to the workspace, i.e. has the same scheme,
  # host and port. Use it to send credentials only to the workspace.
  #
  # @param uri [URI::Generic]
  # @return [Boolean]
  def workspace?(uri)
    return false unless configured?

    workspace = URI.parse(host)
    [ uri.scheme, uri.host&.downcase, uri.port ] == [ workspace.scheme, workspace.host&.downcase, workspace.port ]
  end

  # Returns whether API access was configured.
  #
  # @return [Boolean]
  def configured?
    [ host, user_id, auth_token ].all?(&:present?)
  end
end
