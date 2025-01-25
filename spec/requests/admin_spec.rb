require 'rails_helper'

RSpec.describe "Admin", type: :request do
  context "when logged in as admin" do
    let(:user) { create(:user, :admin) }
    before(:each) { login_as(user) }

    it "can access admin page" do
      get admin_index_path
      expect(response).to have_http_status(:success)
    end

    it "can access edit footer page" do
      get edit_admin_footer_path
      expect(response).to have_http_status(:success)
    end

    it "can access legal documents page" do
      get admin_legal_index_path
      expect(response).to have_http_status(:success)
    end
  end

  context "when logged in as user" do
    let(:user) { create(:user) }
    before(:each) { login_as(user) }

    it "can not access admin page" do
      expect {
        get admin_index_path
      }.to raise_error(CanCan::AccessDenied)
    end

    it "can not access edit footer page" do
      expect {
        get edit_admin_footer_path
      }.to raise_error(CanCan::AccessDenied)
    end

    it "can not access legal documents page" do
      expect {
        get admin_legal_index_path
      }.to raise_error(CanCan::AccessDenied)
    end
  end
end
