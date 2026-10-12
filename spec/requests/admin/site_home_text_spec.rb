require "rails_helper"

RSpec.describe "Admin Site Home Text", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }
  let(:params) do
    { site: { home_title: "Ride with the RCB!", home_title_highlight: "Ride", home_introduction: "First.\n\nSecond." } }
  end

  # Read from the database, as the requests change the site.
  def site = Site.find_or_create_instance

  describe "GET /admin/site/edit" do
    it "shows the default texts as placeholders" do
      login_as(admin)

      get edit_admin_site_path

      page = Nokogiri::HTML(response.body)
      expect(page.at_css("#site-home-text-form #site_home_title")["placeholder"]).to eq("Bring dich aktiv ein!")
      expect(page.at_css("#site-home-text-form #site_home_title")["value"]).to be_nil
      expect(page.at_css("#site-home-text-form #site_home_title_highlight")["placeholder"]).to eq("aktiv")
      expect(page.at_css("#site-home-text-form #site_home_introduction")["placeholder"]).to start_with("Gemeinsam schaffen wir mehr.")
    end
  end

  describe "PUT /admin/site/home_text" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        put admin_site_home_text_path, params:, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(site[:home_title]).to be_nil
      end

      it "rejects unauthorized users" do
        login_as(editor)
        put admin_site_home_text_path, params:, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(site[:home_title]).to be_nil
      end
    end

    it "updates the texts and the preview" do
      login_as(admin)
      put admin_site_home_text_path, params:, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include(I18n.t("notification.saved"), 'target="hero-image-text-preview"', "with the RCB!", "Second.")
      expect(site.home_title).to eq("Ride with the RCB!")
      expect(site.home_title_highlight).to eq("Ride")
      expect(site.home_introduction).to eq("First.\n\nSecond.")
    end

    it "goes back to the default texts when the fields are cleared" do
      Site.create!(name: "Acme", home_title: "Ride with us!", home_introduction: "Hello.")
      login_as(admin)

      put admin_site_home_text_path,
          params: { site: { home_title: "", home_title_highlight: "", home_introduction: "" } },
          as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(site[:home_title]).to be_nil
      expect(site[:home_introduction]).to be_nil
    end

    it "has a reset button next to the save button" do
      login_as(admin)

      get edit_admin_site_path

      page = Nokogiri::HTML(response.body)
      expect(page.css("#site-home-text-form button[type=submit]").map { |button| button.text.squish }).to eq([ "Zurücksetzen", "Speichern" ])
      expect(page.at_css("#site-home-text-form button[form=reset-site-home-text]")).to be_present
      expect(page.at_css("form#reset-site-home-text")["action"]).to eq(admin_site_home_text_path)
    end

    it "responds with an error when the highlight is not part of the headline" do
      login_as(admin)
      put admin_site_home_text_path,
          params: { site: { home_title: "Ride with us!", home_title_highlight: "aktiv" } },
          as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Das hervorgehobene Wort muss in der Überschrift vorkommen.")
      expect(response.body).not_to include('target="hero-image-text-preview"')
      expect(site[:home_title]).to be_nil
    end
  end

  describe "DELETE /admin/site/home_text" do
    before { Site.create!(name: "Acme", home_title: "Ride with us!", home_title_highlight: "Ride", home_introduction: "Hello.") }

    it "rejects unauthorized users" do
      login_as(editor)
      delete admin_site_home_text_path, as: :turbo_stream

      expect(response).to have_http_status(:not_found)
      expect(site[:home_title]).to eq("Ride with us!")
    end

    it "clears the texts, the form and the preview" do
      login_as(admin)
      delete admin_site_home_text_path, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include('target="site-home-text-form"', 'target="hero-image-text-preview"', "Bring dich")
      expect(response.body).not_to include("Ride with us!")
      expect(site.attributes.slice("home_title", "home_title_highlight", "home_introduction").values).to all(be_nil)
    end
  end
end
