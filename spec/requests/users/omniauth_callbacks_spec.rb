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

    it "signs the user in" do
      get user_rocketchat_omniauth_callback_path

      expect(controller.current_user).to eq(User.last)
    end

    it "keeps the user signed in for later requests" do
      get user_rocketchat_omniauth_callback_path
      get dashboard_path

      expect(response).not_to redirect_to(new_user_session_path)
      expect(controller.current_user).to eq(User.last)
    end

    it "remembers the user" do
      get user_rocketchat_omniauth_callback_path

      expect(User.last.remember_created_at).to be_present
      expect(cookies["remember_user_token"]).to be_present
    end

    it "creates the user only once" do
      expect { get user_rocketchat_omniauth_callback_path }.to change(User, :count).by(1)
    end

    context "when a return location is stored" do
      it "redirects to the stored location" do
        get dashboard_path # Unauthenticated, so the location is stored and the user is sent to sign in.
        get user_rocketchat_omniauth_callback_path

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context "when no return location is stored" do
      it "redirects to the root path" do
        get user_rocketchat_omniauth_callback_path

        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user already exists" do
      let!(:existing_user) { create(:user, provider: "rocketchat", uid: "123456") }

      it "signs in the existing user" do
        get user_rocketchat_omniauth_callback_path

        expect(controller.current_user).to eq(existing_user)
      end

      it "does not create a new user" do
        expect { get user_rocketchat_omniauth_callback_path }.not_to change(User, :count)
      end
    end

    context "when the auth data is invalid" do
      before do
        OmniAuth.config.mock_auth[:rocketchat] = OmniAuth::AuthHash.new(
          provider: "rocketchat",
          uid: "123456",
          info: { name: "John Doe", email: nil, nickname: "john.doe", image: nil }
        )
      end

      it "redirects to the sign-in page with the alert" do
        get user_rocketchat_omniauth_callback_path

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq(I18n.t("users.omniauth_callbacks.rocketchat.invalid"))
      end

      it "does not sign the user in" do
        get user_rocketchat_omniauth_callback_path

        expect(controller.current_user).to be_nil
      end

      it "does not create a user" do
        expect { get user_rocketchat_omniauth_callback_path }.not_to change(User, :count)
      end
    end

    context "when another user already has the email" do
      let!(:existing_user) { create(:user, email: "john.doe@example.com") }

      it "redirects to the sign-in page with the alert" do
        get user_rocketchat_omniauth_callback_path

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq(I18n.t("users.omniauth_callbacks.rocketchat.email_taken"))
      end

      it "does not sign the user in" do
        get user_rocketchat_omniauth_callback_path

        expect(controller.current_user).to be_nil
      end

      it "does not create a user or change the existing one" do
        expect { get user_rocketchat_omniauth_callback_path }
          .not_to(change { [ User.count, existing_user.reload.attributes ] })
      end
    end
  end

  describe "GET /users/auth/rocketchat/callback with a failed authentication" do
    before { OmniAuth.config.mock_auth[:rocketchat] = :invalid_credentials }

    it "redirects to the root path with the failure alert" do
      get user_rocketchat_omniauth_callback_path

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq(I18n.t("users.omniauth_callbacks.failure.failure"))
    end
  end
end
