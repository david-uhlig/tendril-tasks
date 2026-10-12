# frozen_string_literal: true

# Downloads the avatars of all users again, which picks up avatars changed in
# Rocket.Chat and those of users who haven't signed in since avatars are
# stored by this app.
class RefreshAvatarsJob < ApplicationJob
  def perform
    User.where.not(avatar_url: "").find_in_batches do |users|
      ActiveJob.perform_all_later(users.map { DownloadAvatarJob.new(it) })
    end
  end
end
