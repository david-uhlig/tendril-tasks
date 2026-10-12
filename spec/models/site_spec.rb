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

  describe "#home_title" do
    it "falls back to the default headline in the current language" do
      expect(site.home_title).to eq("Bring dich aktiv ein!")
      I18n.with_locale(:en) { expect(site.home_title).to eq("Get actively involved!") }
    end

    it "stores a blank headline as missing" do
      site.update!(home_title: " ")

      expect(site.reload[:home_title]).to be_nil
    end

    it "is invalid with more than 100 characters" do
      site.home_title = "a" * 101

      expect(site).not_to be_valid
    end
  end

  describe "#home_title_highlight" do
    it "falls back to the highlight of the default headline" do
      expect(site.home_title_highlight).to eq("aktiv")
    end

    it "has none for an own headline unless set" do
      site.update!(home_title: "Ride with us!")

      expect(site.home_title_highlight).to be_nil
    end

    it "is the part set for an own headline" do
      site.update!(home_title: "Ride with us!", home_title_highlight: "Ride")

      expect(site.home_title_highlight).to eq("Ride")
    end

    it "is invalid when it is not part of the headline" do
      site.home_title = "Ride with us!"
      site.home_title_highlight = "aktiv"

      expect(site).not_to be_valid
      expect(site.errors[:home_title_highlight])
        .to include(I18n.t("activerecord.errors.models.site.attributes.home_title_highlight.not_in_home_title"))
    end
  end

  describe "#home_introduction" do
    it "falls back to the default introduction in the current language" do
      expect(site.home_introduction).to start_with("Gemeinsam schaffen wir mehr.")
    end

    it "is invalid with more than 1000 characters" do
      site.home_introduction = "a" * 1001

      expect(site).not_to be_valid
    end
  end

  describe "#home_introduction_paragraphs" do
    it "splits the introduction at blank lines, as browsers send them" do
      site.home_introduction = "First line,\r\nstill first.\r\n\r\n \r\nSecond.\r\n"

      expect(site.home_introduction_paragraphs).to eq([ "First line,\r\nstill first.", "Second." ])
    end

    it "has one paragraph for the default introduction" do
      expect(site.home_introduction_paragraphs.size).to eq(1)
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

  describe "#hero_image" do
    it "is optional" do
      expect(site).to be_valid
      expect(site.hero_image).not_to be_attached
    end

    it "is valid as a JPEG" do
      site.hero_image.attach(image)

      expect(site).to be_valid
    end

    it "is invalid as another type of file" do
      site.hero_image.attach(image("for-tests.jpg", "application/pdf"))

      expect(site).not_to be_valid
    end

    it "is invalid when larger than 5 MB" do
      site.hero_image.attach(image)
      site.hero_image.blob.byte_size = 6.megabytes

      expect(site).not_to be_valid
    end
  end

  it "can't have a second row" do
    site

    expect { Site.create!(id: 2) }.to raise_error(ActiveRecord::StatementInvalid, /CHECK constraint failed/)
  end
end
