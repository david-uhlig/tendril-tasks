require 'rails_helper'

RSpec.describe Footer::Link, type: :model do
  subject {
    described_class.new("title" => "Example Title",
                        "href" => "http://example.com")
  }

  context "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is not valid without a title" do
      subject.title = nil
      expect(subject).not_to be_valid
    end

    it "is not valid without a href" do
      subject.href = nil
      expect(subject).not_to be_valid
    end
  end

  context "attributes" do
    it "returns a hash of attributes" do
      expect(subject.attributes).to eq({ "title" => "Example Title", "href" => "http://example.com" })
    end
  end
end
