# frozen_string_literal: true

require "rails_helper"

RSpec.describe RefreshAvatarsJob, type: :job do
  it "downloads the avatars of users with an avatar URL" do
    user = create(:user)
    create(:user, avatar_url: "")

    described_class.perform_now

    expect(DownloadAvatarJob).to have_been_enqueued.exactly(:once).with(user)
  end
end
