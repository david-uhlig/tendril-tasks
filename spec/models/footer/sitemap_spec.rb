require 'rails_helper'

RSpec.describe Footer::Sitemap, type: :model do
  let!(:sitemap) { described_class.new }

  describe "a sitemap" do
    it "is not valid without categories" do
      sitemap.categories = []
      expect(sitemap).not_to be_valid
    end

    it "is not valid with an invalid category" do
      invalid_category = Footer::Category.new
      expect(invalid_category).not_to be_valid

      sitemap.categories << invalid_category

      expect(sitemap).not_to be_valid
    end

    it "is valid with a valid category" do
      valid_category = Footer::Category.new
      allow(valid_category).to receive(:valid?).and_return(true)

      sitemap.categories << valid_category

      expect(sitemap).to be_valid
    end
  end

  describe "#attributes" do
    it "returns a hash with categories" do
      category = Footer::Category.new
      sitemap.categories << category
      expect(sitemap.attributes).to be_a(Hash)
      expect(sitemap.attributes.keys).to contain_exactly("categories")
      expect(sitemap.attributes["categories"].first).to eq(category.attributes)
    end
  end

  describe ".load" do
    context "when the footer has links" do
      it "loads it" do
        sitemap = described_class.new
        sitemap.categories << Footer::Category.new(title: "Test Category")
        allow(sitemap).to receive(:valid?).and_return(true)
        sitemap.save

        loaded_sitemap = described_class.load
        expect(loaded_sitemap).to be_a(described_class)
        expect(loaded_sitemap.categories.first.title).to eq(sitemap.categories.first.title)
      end
    end

    context "when the footer has no links" do
      it "returns an empty sitemap" do
        expect(described_class.load).to be_a(described_class)
        expect(described_class.load.categories).to be_empty
      end
    end
  end

  describe "#save" do
    it "saves the links to the footer" do
      sitemap.categories << Footer::Category.new(title: "Test Category")
      allow(sitemap).to receive(:valid?).and_return(true)

      sitemap.save

      expect(Footer.instance.sitemap).to eq(sitemap.attributes)
    end

    it "doesn't save invalid links" do
      expect(sitemap.save).to be(false)
      expect(Footer.count).to eq(0)
    end
  end

  describe "#destroy" do
    it "removes the links from the footer" do
      sitemap.categories << Footer::Category.new(title: "Test Category")
      allow(sitemap).to receive(:valid?).and_return(true)
      sitemap.save

      sitemap.destroy

      expect(Footer.instance.sitemap).to eq({})
    end
  end
end
