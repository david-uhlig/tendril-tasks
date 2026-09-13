# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Account Revokation", type: :request do
  let(:user) { create(:user) }

  # Broader scenario: Ensure that a user cannot access authentication-related
  # pages after account revokation.
  describe "user cannot access profile page after account revokation" do
    context "when a user is authenticated" do
      context "without a remember me token" do
        before(:each) do
          sign_in(user)
          get root_path
          expect(response).to have_http_status(:success)
        end

        it "they can access their profile page" do
          get profile_path
          expect(response).to have_http_status(:success)
          expect(response.body).to include(user.name)
        end

        context "and their account was deleted" do
          before { user.destroy! }

          it "redirects to the login page on the next request" do
            get profile_path
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end

      context "with a remember me token" do
        before(:each) do
          user.remember_me = true
          sign_in(user)

          get root_path
          expect(response).to have_http_status(:success)
        end

        it "they can access their profile page" do
          get profile_path
          expect(response).to have_http_status(:success)
          expect(response.body).to include(user.name)
        end

        context "and their account was deleted" do
          before { user.destroy! }

          it "redirects to the login page on the next request" do
            get profile_path
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end
    end
  end
end
