require "rails_helper"

RSpec.describe "User Dashboard", type: :request do
  let(:user) { create(:user) }

  describe "GET /dashboard" do
    it "requires authentication" do
      require_authentication_for { get dashboard_path }
    end

    context "when authenticated" do
      before(:each) { login_as(user) }

      it "displays the user's dashboard" do
        get dashboard_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Dashboard")
      end
    end
  end
end
