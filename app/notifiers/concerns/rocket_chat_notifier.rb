# frozen_string_literal: true

# Send notification to the Rocket Chat API.
#
# Prequisite:
# - `ROCKET_CHAT_NOTIFIER_HOST`, `ROCKET_CHAT_NOTIFIER_USER_ID`, and
#   `ROCKET_CHAT_NOTIFIER_AUTH_TOKEN` must be defined in a Anyway Config
#   readable format#
# - The including class must implement the `rocket_chat_message` method.
#
# Example:
#   class FooNotifier < ApplicationNotifier
#     include RocketChatNotifier
#
#     notification_methods do
#       def rocket_chat_message
#         "Bar Baz"
#       end
#     end
#   end
module RocketChatNotifier
  extend ActiveSupport::Concern

  included do
    deliver_by :rocket_chat, class: "DeliveryMethods::RocketChat" do |config|
      # The url parameter is required even if the notifier was not configured.
      # So, we just pass in a dummy value.
      config.before_enqueue = -> { throw(:abort) unless RocketChatNotifierConfig.configured? }
      config.url = RocketChatNotifierConfig.url || "https://dummy.example.com"
      config.headers = RocketChatNotifierConfig.headers
      config.json = -> do
        {
          channel: "@#{recipient.username}",
          text: rocket_chat_message
        }
      end
      config.wait = -> { params[:delay].presence }
      config.raise_if_not_ok = true
    end
  end
end
