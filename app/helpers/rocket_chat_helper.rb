# frozen_string_literal: true

module RocketChatHelper
  ROCKET_CHAT_PROTOCOL = "rocketchat://"
  ROCKET_CHAT_HOST = "rcbchat.de"

  def rocketchat_link(to:)
    return "#" unless to.is_a?(User)

    "https://#{ROCKET_CHAT_HOST}/direct/#{to.username}"
  end

  def rocketchat_applink(to:)
    return "#" unless to.is_a?(User)

    room_id = [ to.uid, current_user.uid ].sort.join("")

    "#{ROCKET_CHAT_PROTOCOL}room?host=#{ROCKET_CHAT_HOST}&rid=#{room_id}&path=direct/#{to.username}"
  end
end
