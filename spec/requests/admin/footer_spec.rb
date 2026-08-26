require 'rails_helper'

# Regression coverage for the footer settings endpoints. These mutate global,
# site-wide state (rendered on every page) and must never be reachable without
# admin rights. Prior to this spec, `PATCH /admin/footer/copyright` and the
# sitemap update/destroy actions had no authorization check at all.
#
# Like the other admin controllers (see admin_spec.rb), these do not rescue
# CanCan::AccessDenied, so an unauthorized request raises rather than redirects.
RSpec.describe "Admin::Footer settings", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  let(:valid_sitemap_params) do
    {
      categories: [
        { title: "Community", links: [ { title: "Chat", href: "https://example.com" } ] }
      ]
    }
  end

  describe "PATCH /admin/footer/copyright" do
    context "as a visitor" do
      it "is denied and does not change the copyright" do
        Setting.footer_copyright = "original"

        expect {
          patch admin_footer_copyright_path, params: { copyright_notice: "defaced" }
        }.to raise_error(CanCan::AccessDenied)

        expect(Setting.footer_copyright).to eq("original")
      end
    end

    context "as a user" do
      before(:each) { login_as(user) }

      it "is denied and does not change the copyright" do
        Setting.footer_copyright = "original"

        expect {
          patch admin_footer_copyright_path, params: { copyright_notice: "defaced" }
        }.to raise_error(CanCan::AccessDenied)

        expect(Setting.footer_copyright).to eq("original")
      end
    end

    context "as an admin" do
      before(:each) { login_as(admin) }

      it "updates the copyright" do
        patch admin_footer_copyright_path, params: { copyright_notice: "© Example e.V." }

        expect(Setting.footer_copyright).to eq("© Example e.V.")
      end
    end
  end

  describe "PATCH /admin/footer/sitemap" do
    context "as a visitor" do
      it "is denied and does not change the sitemap" do
        expect {
          patch admin_footer_sitemap_path, params: valid_sitemap_params
        }.to raise_error(CanCan::AccessDenied)

        expect(Setting.footer_sitemap).to eq({})
      end
    end

    context "as a user" do
      before(:each) { login_as(user) }

      it "is denied" do
        expect {
          patch admin_footer_sitemap_path, params: valid_sitemap_params
        }.to raise_error(CanCan::AccessDenied)

        expect(Setting.footer_sitemap).to eq({})
      end
    end

    context "as an admin" do
      before(:each) { login_as(admin) }

      it "stores the sitemap" do
        patch admin_footer_sitemap_path, params: valid_sitemap_params, as: :turbo_stream

        categories = Setting.footer_sitemap.fetch("categories")
        expect(categories.first["title"]).to eq("Community")
      end
    end
  end

  describe "DELETE /admin/footer/sitemap" do
    context "as a visitor" do
      it "is denied and does not remove the sitemap" do
        Setting.footer_sitemap = { "categories" => [ { "title" => "Keep", "links" => [] } ] }

        expect {
          delete admin_footer_sitemap_path
        }.to raise_error(CanCan::AccessDenied)

        expect(Setting.footer_sitemap).not_to eq({})
      end
    end

    context "as an admin" do
      before(:each) { login_as(admin) }

      it "removes the sitemap" do
        Setting.footer_sitemap = { "categories" => [ { "title" => "Keep", "links" => [] } ] }

        delete admin_footer_sitemap_path

        expect(Setting.footer_sitemap).to eq({})
      end
    end
  end
end
