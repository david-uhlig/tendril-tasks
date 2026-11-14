require "rails_helper"

RSpec.describe "Admin Site Logo", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  # Read from the database, as the requests change the logo.
  def logo = Site.find_or_create_instance.logo

  def uploaded_logo(content_type = "image/jpeg")
    Rack::Test::UploadedFile.new(Rails.root.join("spec", "assets", "images", "for-tests.jpg"), content_type)
  end

  describe "GET /admin/site/edit" do
    it "renders the logo file input with its label and helper text in a multipart form" do
      login_as(admin)

      get edit_admin_site_path

      page = Nokogiri::HTML(response.body)
      expect(page.at_css("#site-logo-form")["enctype"]).to eq("multipart/form-data")
      input = page.at_css("#site-logo-form #brand-logo-field input[type=file][name='site[logo]']")
      expect(input["id"]).to eq("site_logo")
      expect(input["aria-invalid"]).to be_nil
      expect(page.at_css("#brand-logo-field label[for=site_logo]")).to be_present
      expect(page.at_css("#brand-logo-field").text).to include(I18n.t("admin.site.edit.navigation.logo.file_field.helper_text"))
    end
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
        field = Nokogiri::HTML(response.body).at_css("#brand-logo-field")
      expect(field.at_css("input[type=file][name='site[logo]']")["aria-invalid"]).to eq("true")
      expect(field.at_css("input[type=file]")["aria-describedby"]).to be_present
      expect(field.text).to match(/\S/).and include(I18n.t("admin.site.edit.navigation.logo.file_field.helper_text"))
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
