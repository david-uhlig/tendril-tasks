require 'rails_helper'

RSpec.describe "Legal", type: :request do
  context "when not logged in" do
    before(:each) {
      page = Page.new(slug: :imprint, content: "Hello, World!")
      page.save!
    }

    it "can access legal pages" do
      get legal_path(:imprint)
      expect(response).to have_http_status(:success)
    end

    it "can not edit legal pages" do
      expect {
        get edit_legal_path(:imprint)
      }.to raise_error(CanCan::AccessDenied)
    end
  end

  context "when logged in as admin" do
    let(:user) { create(:user, :admin) }
    before(:each) { login_as(user) }

    it "can create legal page" do
      get edit_legal_path(:imprint)
      expect(response).to have_http_status(:success)
    end

    it "can edit legal page" do
      page = Page.new(slug: :imprint, content: "Hello!")
      page.save!

      get edit_legal_path(:imprint)
      expect(response).to have_http_status(:success)
    end
  end
end
