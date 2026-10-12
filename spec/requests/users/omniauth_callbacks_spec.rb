# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::OmniauthCallbacks", type: :request do
  around do |example|
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:rocketchat] = OmniAuth::AuthHash.new(
      provider: "rocketchat",
      uid: "123456",
      info: {
        name: "John Doe",
        email: "john.doe@example.com",
        nickname: "john.doe",
        image: "https://chat.example.com/avatar/john.doe"
      }
    )
    example.run
  ensure
    OmniAuth.config.mock_auth.delete(:rocketchat)
    OmniAuth.config.test_mode = false
  end

  describe "GET /users/auth/rocketchat/callback" do
    it "downloads the user's avatar" do
      expect { get user_rocketchat_omniauth_callback_path }
        .to have_enqueued_job(DownloadAvatarJob).with(an_instance_of(User))

      expect(User.last.avatar_url).to eq("https://chat.example.com/avatar/john.doe")
    end
  end
end
