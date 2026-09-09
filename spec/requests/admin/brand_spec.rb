require "rails_helper"

RSpec.describe "Admin Brand", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin/brand/edit" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        require_authentication_for do
          get edit_admin_brand_path
        end
      end

      it "rejects unauthorized users" do
        login_as(editor)
        get edit_admin_brand_path

        expect(response).to have_http_status(:not_found)
      end

      it "allows authorized users" do
        login_as(admin)
        get edit_admin_brand_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
