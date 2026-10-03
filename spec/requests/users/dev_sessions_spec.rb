# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::DevSessions", type: :request do
  let!(:user) { create(:user, name: "Jane Doe", username: "jane.doe") }

  describe "GET /users/sign-in" do
    it "does not show the development sign in outside of development" do
      get new_user_session_path
      expect(response.body).not_to include(dev_user_session_path)
    end

    it "shows the development sign in in development" do
      allow(Rails.env).to receive(:development?).and_return(true)

      get new_user_session_path
      expect(response.body).to include(dev_user_session_path)
      expect(response.body).to include("Jane Doe (jane.doe, user)")
    end
  end

  describe "POST /users/dev-sign-in" do
    it "signs in the chosen user" do
      post dev_user_session_path, params: { user_id: user.id }
      expect(response).to redirect_to(root_path)

      follow_redirect!
      expect(controller.current_user).to eq(user)
    end

    it "redirects to the stored location" do
      get dashboard_path
      post dev_user_session_path, params: { user_id: user.id }
      expect(response).to redirect_to(dashboard_path)
    end

    it "redirects back to the sign in page for an unknown user" do
      post dev_user_session_path, params: { user_id: 0 }
      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to be_present
    end

    it "returns not found in production" do
      allow(Rails.env).to receive(:local?).and_return(false)

      post dev_user_session_path, params: { user_id: user.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end
