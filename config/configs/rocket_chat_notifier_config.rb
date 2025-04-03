# frozen_string_literal: true

class RocketChatNotifierConfig < BaseConfig
  config_name :rocket_chat_notifier

  # Rocket Chat server URL, e.g. "https://example.com"
  attr_config :host
  # Rocket Chat API endpoint for sending messages
  #
  # Typically "/api/v1/chat.postMessage". Must receive POST requests.
  # @see: https://developer.rocket.chat/apidocs/post-message
  attr_config endpoint: "/api/v1/chat.postMessage"
  # Rocket Chat API authentication token and user ID
  # Generate a PAT (Personal Access Token) in Rocket.Chat for the user that will
  # send the notifications.
  #
  # https://example.com/account/tokens
  attr_config :user_id, :auth_token

  # Build headers hash for Rocket.Chat API requests
  # @return [Hash] Headers for Rocket.Chat API requests
  #
  # @example
  #   {
  #     "X-Auth-Token": "ebLUFac6a0QczoD83gCez6HYrthRm8BE_fPaztErvkh",
  #     "X-User-Id": "jXdn9oh5vnJVnWdDY"
  #   }
  def headers
    {
      "X-Auth-Token": auth_token,
      "X-User-Id": user_id
    }
  end

  def url
    return nil unless configured?

    "#{http_host}#{endpoint}"
  end

  def configured?
    @configured ||= host.present? && user_id.present? && auth_token.present?
  end

  private

  def http_host
    if Rails.env == "test"
      "http://example.com"
    elsif host.starts_with?("http://", "https://")
      host
    else
      "https://#{host}"
    end
  end
end
