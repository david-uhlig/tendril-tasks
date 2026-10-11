require "rails_helper"

RSpec.describe Footer, type: :model do
  let(:footer) { Footer.find_or_create_instance }

  describe "#copyright" do
    it "is empty by default" do
      expect(footer.copyright).to eq("")
    end

    it "stores a missing copyright notice as empty" do
      footer.update!(copyright: nil)

      expect(footer.reload.copyright).to eq("")
    end

    it "is valid with 255 characters" do
      footer.copyright = "a" * 255

      expect(footer).to be_valid
    end

    it "is invalid with more than 255 characters" do
      footer.copyright = "a" * 256

      expect(footer).not_to be_valid
      expect(footer.errors[:copyright]).to include(
        I18n.t("activerecord.errors.models.footer.attributes.copyright.too_long", count: 255)
      )
    end
  end

  describe "#sitemap" do
    it "is empty by default" do
      expect(footer.sitemap).to eq({})
    end

    it "stores the links" do
      sitemap = { "categories" => [ { "title" => "Community", "links" => [ { "title" => "Chat", "href" => "https://example.com" } ] } ] }

      footer.update!(sitemap:)

      expect(footer.reload.sitemap).to eq(sitemap)
    end

    it "can't store anything but an object" do
      expect { footer.update_column(:sitemap, []) }.to raise_error(ActiveRecord::StatementInvalid, /CHECK constraint failed/)
    end
  end

  it "can't have a second row" do
    footer

    expect { Footer.create!(id: 2) }.to raise_error(ActiveRecord::StatementInvalid, /CHECK constraint failed/)
  end
end
