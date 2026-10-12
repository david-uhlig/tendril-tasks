# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign-in" do
    context "when Rocket.Chat is configured" do
      it "offers the sign in with Rocket.Chat" do
        get new_user_session_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(user_rocketchat_omniauth_authorize_path)
      end
    end

    context "when Rocket.Chat is not configured" do
      before { allow(RocketChatConfig).to receive(:configured?).and_return(false) }

      it "explains how to configure it instead of offering the sign in" do
        get new_user_session_path
        expect(response.body).not_to include(user_rocketchat_omniauth_authorize_path)
        expect(response.body).to include("ROCKET_CHAT_CLIENT_ID")
      end
    end

    it "shows the logo and the label with a divider, like the navigation" do
      Site.create!(name: "Acme", navigation_label: "ACME")

      get new_user_session_path

      header = Nokogiri::HTML(response.body).at_css("main #brand-logo").parent
      expect(header.at_css("span[aria-hidden='true']")).to be_present
      expect(header.text.squish).to eq("ACME")
    end

    it "shows only the logo when the label is turned off" do
      Site.create!(name: "Acme", display_navigation_label: false)

      get new_user_session_path

      header = Nokogiri::HTML(response.body).at_css("main #brand-logo").parent
      expect(header.at_css("span[aria-hidden='true']")).to be_nil
      expect(header.text.squish).to be_empty
    end

    context "when authenticated" do
      before { login_as(user) }

      it "redirects to the root path" do
        get new_user_session_path
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /users/sign-in" do
    describe "prevent access to disable username/passwort authentication" do
      it "returns not found" do
        post new_user_session_path
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /users/sign-out" do
    context "when unauthenticated" do
      it "redirects to the root path" do
        delete destroy_user_session_path
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when authenticated" do
      it "signs the user out" do
        login_as(user)
        delete destroy_user_session_path
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_path)

        # Ensure the session is cleared and the user is logged out.
        follow_redirect!
        expect(controller.current_user).to be_nil
      end

      it "expires all sessions and remember me tokens when requested" do
        user.update!(remember_created_at: Time.zone.now)
        login_as(user)

        expect {
          delete destroy_user_session_path, params: { expire_all_remember_me_tokens: true }
        }.to change { user.reload.session_token }
          .and change { user.reload.remember_created_at }.to(nil)
      end

      it "keeps sessions and remember me tokens when not requested" do
        user.update!(remember_created_at: Time.zone.now)
        login_as(user)

        expect {
          delete destroy_user_session_path
        }.not_to change { user.reload.session_token }
        expect(user.reload.remember_created_at).to be_present
      end
    end
  end
end
