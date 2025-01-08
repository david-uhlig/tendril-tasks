# frozen_string_literal: true

class RocketChatConfig < BaseConfig
  config_name :rocket_chat
  attr_config :host,
              :client_id,
              :client_secret,
              authorize_url: "/oauth/authorize",
              token_url: "/oauth/token",
              branding: "Rocket.Chat"

  required :host, :client_id, :client_secret,
           env: %w[production development]

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
