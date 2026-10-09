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

    it "renders the copyright and sitemap forms with a filler category and the templates when authorized", :aggregate_failures do
      Setting.footer_sitemap = { "categories" => [ { "title" => "Community", "links" => [ { "title" => "Chat", "href" => "https://example.com" } ] } ] }
      login_as(admin)
      get edit_admin_footer_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Copyright", "Sitemap")
      expect(response.body).to include('value="Community"', 'value="Chat"')
      expect(response.body.scan('class="sitemap-category"').size).to eq(3)
      expect(response.body.scan('name="categories[][links][][title]"').size).to eq(4)
    end

    it "renders the sitemap categories in the footer's left-to-right order" do
      Setting.footer_sitemap = { "categories" => [
        { "title" => "First", "links" => [ { "title" => "A", "href" => "https://example.com/a" } ] },
        { "title" => "Second", "links" => [ { "title" => "B", "href" => "https://example.com/b" } ] }
      ] }
      login_as(admin)
      get edit_admin_footer_path

      expect(response.body.index('value="Second"')).to be < response.body.index('value="First"')
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

    it "updates the sitemap, storing the categories in reverse of the form order, when authorized" do
      login_as(admin)
      patch admin_footer_sitemap_path, params: {
        categories: [
          { title: "Left", links: [ { title: "A", href: "https://example.com/a" } ] },
          { title: "Right", links: [ { title: "B", href: "https://example.com/b" } ] }
        ]
      }, as: :turbo_stream

      expect(response).to have_http_status(:success)
      titles = Setting.footer_sitemap.fetch("categories").map { it["title"] }
      expect(titles).to eq(%w[Right Left])
    end

    it "handles missing categories" do
      login_as(admin)
      patch admin_footer_sitemap_path, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(Setting.footer_sitemap).to eq({})
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
