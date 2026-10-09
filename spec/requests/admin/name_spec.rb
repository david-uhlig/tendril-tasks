require "rails_helper"

RSpec.describe "Admin Brand Name", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "PATCH /admin/brand/name" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        patch admin_brand_name_path,
          params: { name: "Acme", display_name: "1" },
          as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
      end

      it "rejects unauthorized users" do
        login_as(editor)
        patch admin_brand_name_path,
          params: { name: "Acme", display_name: "1" },
          as: :turbo_stream

        expect(response).to have_http_status(:not_found)
      end

      it "updates the brand name and display preference for authorized users" do
        login_as(admin)

        # The brand name is displayed by default, so hiding it shows the change.
        patch admin_brand_name_path,
          params: { name: "Acme", display_name: "0" },
          as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(Setting.brand_name).to eq("Acme")
        expect(Setting.display_brand_name?).to be(false)
      end
    end

    context "when the brand name is too long" do
      before do
        Setting.brand_name = "Acme"
        login_as(admin)
        patch admin_brand_name_path,
          params: { name: "a" * 101, display_name: "0" },
          as: :turbo_stream
      end

      it "responds with an error" do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include(I18n.t("activerecord.errors.models.setting.attributes.value.brand_name_too_long", count: 100))
        expect(response.body).not_to include(I18n.t("notification.saved"))
      end

      it "keeps the brand name and the display preference" do
        expect(Setting.brand_name).to eq("Acme")
        expect(Setting.display_brand_name?).to be(true)
      end
    end
  end
end
