# frozen_string_literal: true

# Configures Rocket Chat (RC) API access.
#
# Most commonly used for sending messages.
class RocketChatApiConfig < BaseConfig
  config_name :rocket_chat_api

  # RC workspace URL, e.g. `example.com`. Use the `url` method to receive a well-formed url
  # including a scheme, host, and api_path.
  attr_config host: "example.com"
  # RC api path, e.g. `/api/v1`.
  attr_config path: "/api/v1"
  # RC API authentication token and user id.
  #
  # Obtain by generating a personal access token (PAT) in RC for the user accessing the API, e.g. at https://<your-rocket-chat-workspace.com>/account/tokens after signing in.
  attr_config :auth_token, :user_id

  # Returns the api URL, e.g. "https://example.com/api/v1"
  def url
    "#{ensure_http_scheme}#{path}"
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

  # Returns whether API access was configured.
  #
  # @return [Boolean]
  def configured?
    @configured ||= [ host, user_id, auth_token ].all?(&:present?)
  end

  private

  def ensure_http_scheme
    host.start_with?(%r{^https?://}i) ? host : "https://#{host}"
  end
end
