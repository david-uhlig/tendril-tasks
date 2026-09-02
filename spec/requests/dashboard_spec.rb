require "rails_helper"

def require_authentication_for(&block)
  block.call if block_given?
  expect(response).to redirect_to(new_user_session_path)
end

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  describe "GET /dashboard" do
    it "requires authentication" do
      require_authentication_for { get dashboard_index_path }
    end

    context "when authenticated" do
      before(:each) { login_as(user) }

      it "displays the user's dashboard" do
        get dashboard_index_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Dashboard")
      end
    end
  end
end
