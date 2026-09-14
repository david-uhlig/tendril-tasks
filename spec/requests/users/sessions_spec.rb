# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign-in" do
    context "when unauthenticated" do
      it "returns a successful response" do
        get new_user_session_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated" do
      before { sign_in(user) }

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
        sign_in(user)
        delete destroy_user_session_path
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_path)

        # Ensure the session is cleared and the user is logged out.
        follow_redirect!
        expect(controller.current_user).to be_nil
      end
    end
  end
end
