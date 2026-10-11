require "rails_helper"

RSpec.describe "Admin Site Identity", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  # Read from the database, as the requests change the site.
  def site = Site.find_or_create_instance

  describe "PUT /admin/site/identity" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        put admin_site_identity_path, params: { site: { name: "Acme" } }, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(site.name).to eq("Tendril Tasks")
      end

      it "rejects unauthorized users" do
        login_as(editor)
        put admin_site_identity_path, params: { site: { name: "Acme" } }, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(site.name).to eq("Tendril Tasks")
      end

      it "updates the site name for authorized users" do
        login_as(admin)
        put admin_site_identity_path, params: { site: { name: "Acme" } }, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include(I18n.t("notification.saved"))
        expect(site.name).to eq("Acme")
      end
    end

    it "updates the navigation label that falls back to the site name" do
      login_as(admin)
      put admin_site_identity_path, params: { site: { name: "Acme" } }, as: :turbo_stream

      expect(response.body).to include('target="brand"', "Acme")
    end

    context "when the site name is invalid" do
      before do
        Site.create!(name: "Acme")
        login_as(admin)
      end

      it "responds with an error and keeps the name when it is blank" do
        put admin_site_identity_path, params: { site: { name: "" } }, as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t("activerecord.errors.models.site.attributes.name.blank"))
        expect(response.body).not_to include(I18n.t("notification.saved"))
        expect(site.name).to eq("Acme")
      end

      it "responds with an error and keeps the name when it is too long" do
        put admin_site_identity_path, params: { site: { name: "a" * 101 } }, as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t("activerecord.errors.models.site.attributes.name.too_long", count: 100))
        expect(site.name).to eq("Acme")
      end
    end
  end
end
