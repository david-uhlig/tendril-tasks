require 'rails_helper'

RSpec.describe Footer::Category, type: :model do
  let(:category) {
    described_class.new("title" => "Example",
                        "links" => [
                          { "title" => "Link1", "href" => "http://example.com" }
                        ])
  }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(category).to be_valid
    end

    it "is invalid without a title" do
      category.title = nil
      expect(category).not_to be_valid
    end

    it "is invalid with invalid links" do
      category.links << Footer::Link.new("title" => "", "href" => "https://example.com")
      expect(category).not_to be_valid
    end

    it "is invalid without links" do
      category.links = []
      expect(category).not_to be_valid
    end
  end

  describe "#attributes" do
    it "returns correct attributes" do
      expected_attributes = { "title" => "Example",
                              "links" => [ { "title" => "Link1", "href" => "http://example.com" } ] }
      expect(category.attributes).to eq(expected_attributes)
    end
  end
end
