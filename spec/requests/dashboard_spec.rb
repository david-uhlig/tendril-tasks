require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  context "when logged in as user" do
    let(:user) { create(:user) }
    before(:each) { login_as(user) }

    it "can access dashboard page" do
      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end
  end
end
