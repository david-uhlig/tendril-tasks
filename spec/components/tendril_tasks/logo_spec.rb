require "rails_helper"

RSpec.describe TendrilTasks::Logo, type: :component do
  # @return [ActionDispatch::TestResponse]
  def rendered_logo_response
    source = Nokogiri::HTML.fragment(rendered_content).at_css("img")["src"]
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.get(URI(source).path)
    session.response || raise("Expected the logo request to return a response")
  end

  context "when the uploaded logo is a JPEG" do
    it "renders the logo as a PNG" do
      Setting.save_brand_logo File.open(Rails.root.join("spec", "assets", "images", "for-tests.jpg"))

      render_inline(described_class.new)

      expect(rendered_content).to have_selector("img")
      response = rendered_logo_response
      expect(response.media_type).to eq("image/png")
      expect(response.body.b).to start_with("\x89PNG\r\n\x1A\n".b)
    end
  end

  context "when the stored logo is a legacy SVG" do
    it "uses the default logo instead of processing the SVG" do
      setting = Setting.create!(key: "brand_logo")
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new('<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>'),
        filename: "legacy.svg",
        content_type: "image/svg+xml"
      )
      ActiveStorage::Attachment.create!(record: setting, name: "attachment", blob: blob)

      render_inline(described_class.new)

      expect(rendered_content).to match(%r{brand/logo-[a-z0-9]+\.svg})
    end
  end
end
