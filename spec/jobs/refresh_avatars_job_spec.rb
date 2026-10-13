# frozen_string_literal: true

require "rails_helper"

RSpec.describe RefreshAvatarsJob, type: :job do
  it "downloads the avatars of users with an avatar URL" do
    user = create(:user)
    create(:user, avatar_url: "")

    # The block form only counts jobs enqueued by this job. The test adapter
    # keeps the jobs of previous examples, which may reference a user with the
    # same id.
    expect { described_class.perform_now }.to have_enqueued_job(DownloadAvatarJob).exactly(:once).with(user)
  end
end
