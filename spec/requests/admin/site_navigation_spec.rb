require "rails_helper"

RSpec.describe "Admin Site Navigation", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  # Read from the database, as the requests change the site.
  def site = Site.find_or_create_instance

  describe "PUT /admin/site/navigation" do
    let(:params) { { site: { navigation_label: "ACME", display_navigation_label: "0" } } }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        put admin_site_navigation_path, params:, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(site.navigation_label).to eq("Tendril Tasks")
      end

      it "rejects unauthorized users" do
        login_as(editor)
        put admin_site_navigation_path, params:, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(site.navigation_label).to eq("Tendril Tasks")
      end

      it "updates the label and whether it's displayed for authorized users" do
        login_as(admin)

        # The label is displayed by default, so hiding it shows the change.
        put admin_site_navigation_path, params:, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(response.body).to include(I18n.t("notification.saved"), 'target="brand"')
        expect(site.navigation_label).to eq("ACME")
        expect(site.display_navigation_label?).to be(false)
      end
    end

    it "falls back to the site name when the label is cleared" do
      Site.create!(name: "Acme", navigation_label: "ACME")
      login_as(admin)

      put admin_site_navigation_path, params: { site: { navigation_label: "", display_navigation_label: "1" } }, as: :turbo_stream

      expect(site[:navigation_label]).to be_nil
      expect(site.navigation_label).to eq("Acme")
    end

    context "when the label is too long" do
      before do
        Site.create!(navigation_label: "ACME")
        login_as(admin)
        put admin_site_navigation_path, params: { site: { navigation_label: "a" * 101, display_navigation_label: "0" } }, as: :turbo_stream
      end

      it "responds with an error" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t("activerecord.errors.models.site.attributes.navigation_label.too_long", count: 100))
        expect(response.body).not_to include(I18n.t("notification.saved"))
      end

      it "keeps the label and whether it's displayed" do
        expect(site.navigation_label).to eq("ACME")
        expect(site.display_navigation_label?).to be(true)
      end
    end
  end
end
