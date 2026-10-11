require "rails_helper"

RSpec.describe "Admin Site", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin/site/edit" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        require_authentication_for do
          get edit_admin_site_path
        end
      end

      it "rejects unauthorized users" do
        login_as(editor)
        get edit_admin_site_path

        expect(response).to have_http_status(:not_found)
      end

      it "allows authorized users" do
        login_as(admin)
        get edit_admin_site_path

        expect(response).to have_http_status(:success)
      end
    end

    it "shows the site name as the placeholder of a label that falls back to it" do
      Site.create!(name: "Acme")
      login_as(admin)

      get edit_admin_site_path

      field = Nokogiri::HTML(response.body).at_css("#site_navigation_label")
      expect(field["value"]).to be_nil
      expect(field["placeholder"]).to eq("Acme")
    end

    it "shows a label of its own" do
      Site.create!(name: "Acme", navigation_label: "ACME")
      login_as(admin)

      get edit_admin_site_path

      expect(Nokogiri::HTML(response.body).at_css("#site_navigation_label")["value"]).to eq("ACME")
    end
  end
end
