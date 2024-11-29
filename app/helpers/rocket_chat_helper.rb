# frozen_string_literal: true

module RocketChatHelper
  ROCKET_CHAT_DEEPLINK_HOST = "https://go.rocket.chat"
  ROCKET_CHAT_HOST = "rcbchat.de"

  # Generates a deep link for sending a personal message in Rocket.Chat.
  # Opens the link in the native app (iOS/Android/Desktop) or the web browser.
  #
  # @param to [User] The recipient of the personal message.
  #
  # @see https://developer.rocket.chat/v1/docs/en/deep-linking
  # @see Rocket.Chat Electron deep link handling:
  #   https://github.com/RocketChat/Rocket.Chat.Electron/blob/1106a888ef3c3e82f1e3a41dc7b892c02c41f0d8/src/deepLinks/main.ts#L146
  def rocketchat_pm(to:)
    return "#" unless to.is_a?(User)
    return "#" if to.id == current_user.id

    room_id = "#{to.uid}#{current_user.uid}"

    # rid for mobile, path for web-clients
    "#{ROCKET_CHAT_DEEPLINK_HOST}/room?host=#{ROCKET_CHAT_HOST}&rid=#{room_id}&path=direct/#{room_id}"
  end
end
