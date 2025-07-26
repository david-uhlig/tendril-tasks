# frozen_string_literal: true

Devise.setup do |config|
  config.omniauth :rocketchat,
                  RocketChatConfig.client_id,
                  RocketChatConfig.client_secret,
                  client_options: {
                    site: RocketChatConfig.omniauth_host
                  }
end
