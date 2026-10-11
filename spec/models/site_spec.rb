require "rails_helper"

RSpec.describe Site, type: :model do
  let(:site) { Site.find_or_create_instance }

  def image(filename = "for-tests.jpg", content_type = "image/jpeg")
    { io: File.open(Rails.root.join("spec", "assets", "images", filename)), filename:, content_type: }
  end

  describe "defaults" do
    it "is named Tendril Tasks and displays the label in the navigation" do
      expect(site).to have_attributes(name: "Tendril Tasks", tagline: nil, display_navigation_label: true)
      expect(site.logo).not_to be_attached
    end
  end

  describe "#name" do
    it "is required" do
      site.name = ""

      expect(site).not_to be_valid
      expect(site.errors[:name]).to include(I18n.t("activerecord.errors.models.site.attributes.name.blank"))
    end

    it "is invalid with more than 100 characters" do
      site.name = "a" * 101

      expect(site).not_to be_valid
      expect(site.errors[:name]).to include(I18n.t("activerecord.errors.models.site.attributes.name.too_long", count: 100))
    end
  end

  describe "#tagline" do
    it "stores a blank tagline as missing" do
      site.update!(tagline: " ")

      expect(site.reload.tagline).to be_nil
    end

    it "is invalid with more than 100 characters" do
      site.tagline = "a" * 101

      expect(site).not_to be_valid
    end
  end

  describe "#navigation_label" do
    it "falls back to the site name" do
      site.update!(name: "Acme")

      expect(site.navigation_label).to eq("Acme")
    end

    it "returns a label of its own" do
      site.update!(name: "Acme", navigation_label: "ACME")

      expect(site.navigation_label).to eq("ACME")
    end

    it "stores a blank label as missing, so it falls back to the site name" do
      site.update!(name: "Acme", navigation_label: "")

      expect(site.reload[:navigation_label]).to be_nil
      expect(site.navigation_label).to eq("Acme")
    end

    it "is invalid with more than 100 characters" do
      site.navigation_label = "a" * 101

      expect(site).not_to be_valid
    end
  end

  describe "#logo" do
    it "is valid as a JPEG" do
      site.logo.attach(image)

      expect(site).to be_valid
    end

    it "is invalid as another type of file" do
      site.logo.attach(image("for-tests.jpg", "application/pdf"))

      expect(site).not_to be_valid
    end
  end

  it "can't have a second row" do
    site

    expect { Site.create!(id: 2) }.to raise_error(ActiveRecord::StatementInvalid, /CHECK constraint failed/)
  end
end
