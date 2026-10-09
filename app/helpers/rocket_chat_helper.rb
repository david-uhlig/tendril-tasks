# frozen_string_literal: true

module RocketChatHelper
  ROCKET_CHAT_PROTOCOL = "rocketchat://"

  # Sign in buttons start the Rocket.Chat login when it is configured.
  # Otherwise, they lead to the sign in page, which offers the development sign
  # in.
  def rocketchat_sign_in_path
    RocketChatConfig.configured? ? user_rocketchat_omniauth_authorize_path : new_user_session_path
  end

  def rocketchat_sign_in_method
    RocketChatConfig.configured? ? :post : :get
  end

  def rocketchat_link(to:)
    return "#" unless to.is_a?(User)

    "#{RocketChatConfig.host}/direct/#{to.username}"
  end

  def rocketchat_applink(to:)
    return "#" unless to.is_a?(User)

    room_id = [ to.uid, current_user.uid ].sort.join("")

    "#{ROCKET_CHAT_PROTOCOL}room?host=#{RocketChatConfig.host}&rid=#{room_id}&path=direct/#{to.username}"
  end
end
