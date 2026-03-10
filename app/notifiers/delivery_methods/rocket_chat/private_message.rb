# frozen_string_literal: true

# Send a private message to a Rocket Chat recipient.
#
# @example Basic usage
#   class NewCommentNotification < ApplicationNotification
#     deliver_by :rocket_chat_pm, class: "DeliveryMethods::RocketChat::PrivateMessage" do |config|
#       config.url = "https://example.com/api/v1"
#       config.headers = -> {
#        "X-Auth-Token": "ebLUFac6a0QczoD83gCez6HYrthRm8BE_fPaztErvkh",
#        "X-User-Id": "jXdn9oh5vnJVnWdDY"
#       }
#       config.recipient = recipient.username
#       config.message = "New comment on your post: #{comment_url}"
#       config.raise_if_not_ok = true
#     end
#   end
#
# @param url [String] The URL to the Rocket Chat API, e.g. `https://example.com/api/v1`
# @param headers [Hash] The request headers as required by the endpoint, e.g. containing `X-Auth-Token` and `X-User-Id`. The token can be a personal access token (PAT) from the Rocket Chat user sending the message.
#
# @see https://developer.rocket.chat/apidocs/post-message
class DeliveryMethods::RocketChat::PrivateMessage < ApplicationDeliveryMethod
  required_options :url, :headers, :message
  attr_reader :response

  ENDPOINT = "/chat.postMessage"

  def deliver
    url, headers, message = %i[url headers message].map { evaluate_option(it) }
    private_message_endpoint = "#{url}#{ENDPOINT}"
    payload = { channel: "@#{recipient.username}", text: message }
    @response = post_request(private_message_endpoint, headers:, json: payload)

    if raise_if_not_ok? && !response_http_ok?
      raise ::Noticed::ResponseUnsuccessful.new(@response, private_message_endpoint, { headers:, json: payload })
    end

    @response
  end

  def raise_if_not_ok?
    option = evaluate_option(:raise_if_not_ok)
    option.nil? ? true : option
  end

  def response_http_ok?
    response.code == "200"
  end
end
