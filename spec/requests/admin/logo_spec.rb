require "rails_helper"

RSpec.describe "Admin Brand Logo", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "PATCH /admin/brand/logo" do
    let(:logo) { File.open(Rails.root.join('spec', 'assets', 'images', 'for-tests.jpg')) }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        patch admin_brand_logo_path, params: { logo: logo }, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
      end

      it "rejects unauthorized users" do
        login_as(editor)
        patch admin_brand_logo_path, params: { logo: logo }, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
      end

      it "updates the brand logo for authorized users" do
        login_as(admin)
        allow(Setting).to receive(:brand_logo=)

        patch admin_brand_logo_path, params: { logo: logo }, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(Setting).to have_received(:brand_logo=)
      end
    end
  end

  describe "DELETE /admin/brand/logo" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        delete admin_brand_logo_path, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
      end

      it "rejects unauthorized users" do
        login_as(editor)
        delete admin_brand_logo_path, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
      end

      it "removes the brand logo for authorized users" do
        login_as(admin)

        delete admin_brand_logo_path, as: :turbo_stream

        expect(response).to have_http_status(:success)
      end
    end
  end
end
