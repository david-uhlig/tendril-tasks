# frozen_string_literal: true

Devise.setup do |config|
  config.omniauth(
    :rocketchat,
    RocketChatConfig.client_id,
    RocketChatConfig.client_secret,
    pkce: RocketChatConfig.pkce,
    client_options: {
      site: RocketChatConfig.host
    }
  )
end
