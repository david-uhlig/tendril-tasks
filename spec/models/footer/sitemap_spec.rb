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
    context "when the sitemap exists in the settings table" do
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

    context "when the sitemap does not exist in the settings table" do
      it "returns an empty sitemap" do
        expect(described_class.load).to be_a(described_class)
        expect(described_class.load.categories).to be_empty
      end
    end
  end

  describe "#save" do
    it "saves the sitemap to the settings table" do
      allow(sitemap).to receive(:valid?).and_return(true)
      expect { sitemap.save }.to change(Setting, :count).by(1)
    end
  end

  describe "#destroy" do
    it "destroys the sitemap" do
      allow(sitemap).to receive(:valid?).and_return(true)
      sitemap.save
      expect { sitemap.destroy }.to change(Setting, :count).by(-1)
    end
  end
end
