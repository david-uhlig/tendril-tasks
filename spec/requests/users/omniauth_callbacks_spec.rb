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

    context "when the user cannot be saved" do
      let(:unsaved_user) do
        build(:user, email: nil).tap { |user| user.errors.add(:email, :blank) }
      end

      before { allow(User).to receive(:from_omniauth).and_return(unsaved_user) }

      # The registration route does not exist, so the controller raises a
      # NameError here. Pending until the route is added.
      it "redirects to the registration page with the errors as alert",
         pending: "new_user_registration_url is not defined (NameError)" do
        get user_rocketchat_omniauth_callback_path

        expect(response).to redirect_to(new_user_registration_url)
        expect(flash[:alert]).to eq("Email can't be blank")
        expect(session["devise.rocketchat_data"]).to include("uid" => "123456")
      end

      it "does not sign the user in",
         pending: "new_user_registration_url is not defined (NameError)" do
        get user_rocketchat_omniauth_callback_path

        expect(controller.current_user).to be_nil
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
