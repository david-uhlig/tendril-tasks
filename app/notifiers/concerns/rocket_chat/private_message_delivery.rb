# frozen_string_literal: true

# Delivers a private message to a Rocket Chat recipient.
#
# Include this concern in a notification class.
#
# @example Basic usage
# The including class must implement `markdown_message` like below that returns the message to be sent to the recipient.
#
#   class NewCommentNotification < ApplicationNotification
#     include RocketChat::PrivateMessageDelivery
#
#     notification_methods do
#       def markdown_message
#         "message to the recipient"
#       end
#     end
#   end
module RocketChat::PrivateMessageDelivery
  extend ActiveSupport::Concern

  included do
    deliver_by :rocket_chat_pm, class: "DeliveryMethods::RocketChat::PrivateMessage" do |config|
      api_config = RocketChatApiConfig
      config.before_enqueue = -> { throw(:abort) unless api_config.configured? }
      config.url = api_config.url
      config.headers = api_config.auth_headers
      config.message = -> { markdown_message }
      config.wait = -> { params[:delay].presence }
      config.raise_if_not_ok = true
    end
  end
end
