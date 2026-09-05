require "rails_helper"

RSpec.describe "Admin::Footer settings", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  let(:valid_sitemap_params) do
    {
      categories: [
        { title: "Community", links: [ { title: "Chat", href: "https://example.com" } ] }
      ]
    }
  end

  describe "GET /admin/footer" do
    it "requires authentication" do
      require_authentication_for { get edit_admin_footer_path }
    end

    it "rejects unauthorized access" do
      login_as(editor)

      get edit_admin_footer_path
      expect(response).to have_http_status(:not_found)
    end

    it "displays the footer edit page when authorized" do
      login_as(admin)
      get edit_admin_footer_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Copyright")
      expect(response.body).to include("Sitemap")
    end
  end

  describe "PATCH /admin/footer/copyright" do
    it "requires authentication" do
      Setting.footer_copyright = "original"

      require_authentication_for do
        patch admin_footer_copyright_path, params: { copyright_notice: "defaced" }
      end

      expect(Setting.footer_copyright).to eq("original")
    end

    it "denies unauthorized changes" do
      Setting.footer_copyright = "original"

      login_as(editor)
      patch admin_footer_copyright_path, params: { copyright_notice: "defaced" }

      expect(response).to have_http_status(:not_found)
      expect(Setting.footer_copyright).to eq("original")
    end

    it "updates the copyright notice when authorized" do
      login_as(admin)
      patch admin_footer_copyright_path, params: { copyright_notice: "© Example e.V." }
      expect(response).to have_http_status(:found)
      expect(Setting.footer_copyright).to eq("© Example e.V.")
    end
  end

  describe "PATCH /admin/footer/sitemap" do
    it "requires authentication" do
      require_authentication_for do
        patch admin_footer_sitemap_path, params: valid_sitemap_params
      end

      expect(Setting.footer_sitemap).to eq({})
    end

    it "denies unauthorized changes" do
      login_as(editor)

      patch admin_footer_sitemap_path, params: valid_sitemap_params, as: :turbo_stream
      expect(response).to have_http_status(:not_found)
      expect(Setting.footer_sitemap).to eq({})
    end

    it "updates the sitemap when authorized" do
      login_as(admin)
      patch admin_footer_sitemap_path, params: valid_sitemap_params, as: :turbo_stream

      expect(response).to have_http_status(:success)
      categories = Setting.footer_sitemap.fetch("categories")
      expect(categories.first["title"]).to eq("Community")
    end
  end

  describe "DELETE /admin/footer/sitemap" do
    it "requires authentication" do
      Setting.footer_sitemap = { "categories" => [ { "title" => "Keep", "links" => [] } ] }

      require_authentication_for { delete admin_footer_sitemap_path }

      expect(Setting.footer_sitemap).not_to eq({})
    end

    it "denies unauthorized deletions" do
      Setting.footer_sitemap = { "categories" => [ { "title" => "Keep", "links" => [] } ] }

      login_as(editor)
      delete admin_footer_sitemap_path

      expect(response).to have_http_status(:not_found)
      expect(Setting.footer_sitemap).not_to eq({})
    end

    it "deletes the sitemap when authorized" do
      login_as(admin)
      Setting.footer_sitemap = { "categories" => [ { "title" => "Keep", "links" => [] } ] }
      delete admin_footer_sitemap_path
      expect(response).to have_http_status(:found)
      expect(Setting.footer_sitemap).to eq({})
    end
  end
end
