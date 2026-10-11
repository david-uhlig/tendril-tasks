require "rails_helper"

RSpec.describe "Admin Site Logo", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  # Read from the database, as the requests change the logo.
  def logo = Site.find_or_create_instance.logo

  def uploaded_logo(content_type = "image/jpeg")
    Rack::Test::UploadedFile.new(Rails.root.join("spec", "assets", "images", "for-tests.jpg"), content_type)
  end

  describe "PUT /admin/site/logo" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        put admin_site_logo_path, params: { site: { logo: uploaded_logo } }, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(logo).not_to be_attached
      end

      it "rejects unauthorized users" do
        login_as(editor)
        put admin_site_logo_path, params: { site: { logo: uploaded_logo } }, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(logo).not_to be_attached
      end

      it "saves the logo for authorized users" do
        login_as(admin)

        put admin_site_logo_path, params: { site: { logo: uploaded_logo } }, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(response.body).to include('target="current-brand-logo"')
        expect(logo.filename.to_s).to eq("for-tests.jpg")
      end

      it "displays validation errors for an invalid logo upload and keeps the logo" do
        Site.find_or_create_instance.update!(logo: uploaded_logo)
        login_as(admin)

        put admin_site_logo_path, params: { site: { logo: uploaded_logo("application/pdf") } }, as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("error-message-for-logo")
        expect(response.body).not_to include('target="current-brand-logo"')
        expect(logo.content_type).to eq("image/jpeg")
      end
    end
  end

  describe "DELETE /admin/site/logo" do
    before { Site.find_or_create_instance.update!(logo: uploaded_logo) }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        delete admin_site_logo_path, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(logo).to be_attached
      end

      it "rejects unauthorized users" do
        login_as(editor)
        delete admin_site_logo_path, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(logo).to be_attached
      end

      it "removes the logo for authorized users" do
        login_as(admin)

        delete admin_site_logo_path, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(logo).not_to be_attached
        expect(response.body).to include("brand/logo")
        expect(response.body).not_to include("active_storage")
      end
    end
  end
end
