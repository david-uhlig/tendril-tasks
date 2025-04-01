# frozen_string_literal: true

# Send a POST request to the Rocket.Chat API.
#
# Most commonly used with the `https://example.com/api/v1/chat.postMessage`
# endpoint. See: https://developer.rocket.chat/apidocs/post-message
#
# == Usage
#
#   class NewCommentNotifier < ApplicationNotifier
#     deliver_by :rocket_chat, class: "DeliveryMethods::RocketChat" do |config|
#       config.url = "https://example.com/api/v1/chat.postMessage"
#       config.headers = -> {
#        "X-Auth-Token": "ebLUFac6a0QczoD83gCez6HYrthRm8BE_fPaztErvkh",
#        "X-User-Id": "jXdn9oh5vnJVnWdDY"
#       }
#       config.json = -> {
#         channel: "@#{recipient.username}",
#         text: "New comment on your post: #{comment_url}"
#       }
#       config.raise_if_not_ok = true
#     end
#   end
#
# == Parameters
#
# @param [String] url The fully qualified URL to send the request to, e.g. `https://example.com/api/v1/chat.postMessage`
# @param [Hash] headers The headers to include in the request. Most endpoints require `X-Auth-Token` and `X-User-Id` for authentication. May be a PAT from the Rocket Chat user sending the request.
# @param [Hash] json The JSON payload to include in the request body. Dependend on the endpoint.
# @param [Boolean] raise_if_not_ok If true, raises an error if the response is not successful (HTTP status code 200). Defaults to true.
#
# See also: https://github.com/excid3/noticed?tab=readme-ov-file for additional general purpose configuration options.
class DeliveryMethods::RocketChat < ApplicationDeliveryMethod
  required_options :url, :json, :headers

  def deliver
    url = evaluate_option(:url)
    headers = evaluate_option(:headers)
    json = evaluate_option(:json)
    response = post_request url, headers: headers, json: json

    if raise_if_not_ok?
      raise ::Noticed::ResponseUnsuccessful.new(response, url, { headers: headers, json: json }) unless response_successful?(response)
    end

    response
  end

  def response_successful?(response)
    response.code.to_i == 200
  end

  def raise_if_not_ok?
    value = evaluate_option(:raise_if_not_ok)
    value.nil? ? true : value
  end
end
