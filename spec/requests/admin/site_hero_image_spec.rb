require "rails_helper"

RSpec.describe "Admin Site Hero Image", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  # Read from the database, as the requests change the picture.
  def hero_image = Site.find_or_create_instance.hero_image

  def uploaded_image(content_type = "image/jpeg")
    Rack::Test::UploadedFile.new(Rails.root.join("spec", "assets", "images", "for-tests.jpg"), content_type)
  end

  describe "GET /admin/site/edit" do
    it "shows the default photo in the home page section" do
      login_as(admin)

      get edit_admin_site_path

      page = Nokogiri::HTML(response.body)
      expect(page.at_css("#site-hero-image-form #hero-image-field")).to be_present
      expect(page.at_css("#current-hero-image figcaption").text.squish).to eq("Standardfoto von Anna Schroeder auf Unsplash")
    end

    it "offers to show the picture with the home page text" do
      login_as(admin)

      get edit_admin_site_path

      page = Nokogiri::HTML(response.body)
      expect(page.at_css("#current-hero-image label").text.squish).to eq("Mit dem Text der Startseite zeigen")
      expect(page.at_css("#current-hero-image input#hero-image-show-text[type=checkbox]")).to be_present
      expect(page.at_css("#hero-image-text-preview").text.squish).to include("Bring dich aktiv ein!", "Aufgabe finden")
    end
  end

  describe "PUT /admin/site/hero_image" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        put admin_site_hero_image_path, params: { site: { hero_image: uploaded_image } }, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(hero_image).not_to be_attached
      end

      it "rejects unauthorized users" do
        login_as(editor)
        put admin_site_hero_image_path, params: { site: { hero_image: uploaded_image } }, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(hero_image).not_to be_attached
      end
    end

    it "saves the picture and shows it" do
      login_as(admin)

      put admin_site_hero_image_path, params: { site: { hero_image: uploaded_image } }, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(response.body).to include('target="current-hero-image"', "<img")
      expect(hero_image.filename.to_s).to eq("for-tests.jpg")
    end

    it "displays validation errors for an invalid upload and keeps the picture" do
      Site.find_or_create_instance.update!(hero_image: uploaded_image)
      login_as(admin)

      put admin_site_hero_image_path, params: { site: { hero_image: uploaded_image("application/pdf") } }, as: :turbo_stream

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("error-message-for-hero_image")
      expect(response.body).not_to include('target="current-hero-image"')
      expect(hero_image.content_type).to eq("image/jpeg")
    end
  end

  describe "DELETE /admin/site/hero_image" do
    before { Site.find_or_create_instance.update!(hero_image: uploaded_image) }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        delete admin_site_hero_image_path, as: :turbo_stream

        expect(response).to redirect_to(new_user_session_path)
        expect(hero_image).to be_attached
      end

      it "rejects unauthorized users" do
        login_as(editor)
        delete admin_site_hero_image_path, as: :turbo_stream

        expect(response).to have_http_status(:not_found)
        expect(hero_image).to be_attached
      end
    end

    it "removes the picture and shows the default photo again" do
      login_as(admin)

      delete admin_site_hero_image_path, as: :turbo_stream

      expect(response).to have_http_status(:success)
      expect(hero_image).not_to be_attached
      expect(response.body).to include('target="current-hero-image"', "Standardfoto")
    end
  end
end
