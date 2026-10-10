require "rails_helper"

RSpec.describe "Admin Brand Logo", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  def uploaded_logo(content_type = "image/jpeg")
    Rack::Test::UploadedFile.new(Rails.root.join("spec", "assets", "images", "for-tests.jpg"), content_type)
  end

  describe "PATCH /admin/brand/logo" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        patch admin_brand_logo_path, params: { setting: { attachment: uploaded_logo } }, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(Setting.brand_logo).to be_nil
      end

      it "rejects unauthorized users" do
        login_as(editor)
        patch admin_brand_logo_path, params: { setting: { attachment: uploaded_logo } }, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(Setting.brand_logo).to be_nil
      end

      it "saves the brand logo for authorized users" do
        login_as(admin)

        patch admin_brand_logo_path, params: { setting: { attachment: uploaded_logo } }, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(Setting.brand_logo.filename.to_s).to eq("for-tests.jpg")
      end

      it "displays validation errors for an invalid logo upload" do
        login_as(admin)

        patch admin_brand_logo_path, params: { setting: { attachment: uploaded_logo("application/pdf") } }, as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("error-message-for-attachment")
        expect(response.body).not_to include('target="current-brand-logo"')
      end
    end
  end

  describe "DELETE /admin/brand/logo" do
    before { Setting.save_brand_logo(uploaded_logo) }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        delete admin_brand_logo_path, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(Setting.brand_logo).to be_present
      end

      it "rejects unauthorized users" do
        login_as(editor)
        delete admin_brand_logo_path, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(Setting.brand_logo).to be_present
      end

      it "removes the brand logo for authorized users" do
        login_as(admin)

        delete admin_brand_logo_path, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(Setting.brand_logo).to be_nil
        expect(response.body).to include("brand/logo")
        expect(response.body).not_to include("active_storage")
      end
    end
  end
end
