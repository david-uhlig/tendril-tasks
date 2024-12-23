require 'rails_helper'

RSpec.describe "Admin", type: :request do
  context "when logged in as admin" do
    let(:user) { create(:user, :admin) }
    before(:each) { login_as(user) }

    it "can access admin page" do
      get admin_index_path
      expect(response).to have_http_status(:success)
    end
  end
end
