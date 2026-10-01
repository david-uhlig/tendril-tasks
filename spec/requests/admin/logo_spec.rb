require "rails_helper"

RSpec.describe "Admin Brand Logo", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "PATCH /admin/brand/logo" do
    let(:logo) { File.open(Rails.root.join('spec', 'assets', 'images', 'for-tests.jpg')) }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        patch admin_brand_logo_path, params: { setting: { attachment: logo } }, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
      end

      it "rejects unauthorized users" do
        login_as(editor)
        patch admin_brand_logo_path, params: { logo: logo }, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
      end

      it "displays validation errors for an invalid logo upload" do
        login_as(admin)
        invalid_logo = Rack::Test::UploadedFile.new(logo.path, "application/pdf")

        patch admin_brand_logo_path, params: { setting: { attachment: invalid_logo } }, as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("error-message-for-attachment")
        expect(response.body).not_to include('target="current-brand-logo"')
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
