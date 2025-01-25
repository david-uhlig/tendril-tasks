require 'rails_helper'

RSpec.describe Footer::Sitemap, type: :model do
  let(:sitemap) {
    described_class.new("categories" => [
      {
        "title" => "Example",
        "links" => [
          {
            "title" => "Example",
            "href" => "https://example.com"
          }
        ]
      }
    ])
  }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(sitemap).to be_valid
    end

    it "is not valid without categories" do
      sitemap.categories = []
      expect(sitemap).not_to be_valid
    end
  end

  describe "#attributes" do
    it "returns correct attributes" do
      expected_attributes = { "categories" => [
        {
          "title" => "Example",
          "links" => [
            {
              "title" => "Example",
              "href" => "https://example.com"
            }
          ]
        }
      ] }
      expect(sitemap.attributes).to eq(expected_attributes)
    end
  end
end
