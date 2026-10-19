require "rails_helper"

RSpec.describe TendrilTasks::Logo, type: :component do
  # @return [ActionDispatch::TestResponse]
  def rendered_logo_response
    source = Nokogiri::HTML.fragment(rendered_content).at_css("img")["src"]
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.get(URI(source).path)
    session.response || raise("Expected the logo request to return a response")
  end

  # @return [ActiveStorage::Variation] the variation the rendered logo is served with
  def rendered_variation
    path = URI(Nokogiri::HTML.fragment(rendered_content).at_css("img")["src"]).path
    ActiveStorage::Variation.decode(path.split("/")[-2])
  end

  describe "resize height" do
    before do
      Site.find_or_create_instance.logo.attach(io: File.open(Rails.root.join("spec", "assets", "images", "for-tests.jpg")), filename: "for-tests.jpg")
    end

    { sm: 44, lg: 64, none: 44 }.each do |size, height|
      it "requests a logo #{height}px high for size #{size}" do
        render_inline(described_class.new(size:))

        expect(rendered_variation.transformations).to include(resize_to_fit: [ nil, height ])
      end
    end
  end

  describe "alt text" do
    before do
      Site.find_or_create_instance.update!(name: "Acme", navigation_label: "ACME")
    end

    it "names the logo with the site's navigation label when the uploaded logo is shown" do
      Site.find_or_create_instance.logo.attach(io: File.open(Rails.root.join("spec", "assets", "images", "for-tests.jpg")), filename: "for-tests.jpg")

      render_inline(described_class.new)

      expect(page).to have_selector("img[alt='ACME']")
    end

    it "names the default logo with the site's navigation label" do
      render_inline(described_class.new)

      expect(page).to have_selector("img[alt='ACME'][src*='brand/logo']")
    end
  end

  context "when the uploaded logo is a JPEG" do
    it "renders the logo as a PNG" do
      Site.find_or_create_instance.logo.attach(io: File.open(Rails.root.join("spec", "assets", "images", "for-tests.jpg")), filename: "for-tests.jpg")

      render_inline(described_class.new)

      expect(rendered_content).to have_selector("img")
      response = rendered_logo_response
      expect(response.media_type).to eq("image/png")
      expect(response.body.b).to start_with("\x89PNG\r\n\x1A\n".b)
    end
  end

  context "when the stored logo is a legacy SVG" do
    it "uses the default logo instead of processing the SVG" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new('<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>'),
        filename: "legacy.svg",
        content_type: "image/svg+xml"
      )
      ActiveStorage::Attachment.create!(record: Site.find_or_create_instance, name: "logo", blob: blob)

      render_inline(described_class.new)

      expect(rendered_content).to match(%r{brand/logo-[a-z0-9]+\.svg})
    end
  end
end
