require 'rails_helper'

RSpec.describe Footer::Data, type: :model do
  let(:data) { described_class.new }

  describe "#cache_key" do
    include ActiveSupport::Testing::TimeHelpers

    let!(:imprint_page) { create(:page, slug: "imprint") }

    before do
      Setting.footer_copyright = "© Example"
      Setting.footer_sitemap = { "categories" => [] }
      travel 1.minute
    end

    def cache_key
      Current.reset
      described_class.new.cache_key
    end

    it "stays the same without changes" do
      expect(cache_key).to eq(cache_key)
    end

    it "changes when a setting changes" do
      expect { Setting.footer_copyright = "© Changed" }.to change { cache_key }
    end

    it "doesn't return to the key of an earlier footer when a setting is removed" do
      Setting.footer_copyright = "© Changed"
      key_with_sitemap = cache_key
      travel 1.minute
      Setting.footer_sitemap = { "categories" => [ { "title" => "Newer", "links" => [] } ] }

      Setting.remove("footer_sitemap")

      expect(cache_key).not_to eq(key_with_sitemap)
    end

    it "changes when a legal page changes" do
      expect { imprint_page.update!(content: "Changed") }.to change { cache_key }
    end

    it "changes when a legal page is deleted" do
      expect { imprint_page.destroy }.to change { cache_key }
    end

    it "stays the same when another page changes" do
      other_page = create(:page, slug: "other")
      travel 1.minute
      expect { other_page.update!(content: "Changed") }.not_to change { cache_key }
    end
  end

  describe "#legal" do
    let(:imprint_page) { create(:page, slug: "imprint") }
    let(:privacy_page) { create(:page, slug: "privacy-policy") }
    let(:other_page) { create(:page, slug: "other") }

    it "returns an empty array when there are no pages" do
      expect(data.legal).to be_empty
    end

    it "returns an empty array when there are no legal pages" do
      other_page
      expect(data.legal).to be_empty
    end

    it "returns the slugs of legal pages" do
      imprint_page
      privacy_page
      other_page

      expect(data.legal).to contain_exactly("imprint", "privacy-policy")
    end
  end

  describe "#sitemap" do
    it "returns a Footer::Sitemap object" do
      expect(data.sitemap).to be_a(Footer::Sitemap)
    end
  end

  describe "#copyright" do
    it "returns an empty string when there is no footer copyright" do
      expect(data.copyright).to eq("")
    end

    it "returns the footer copyright" do
      create(:setting, key: "footer_copyright", value: "© 2021 Example")

      expect(data.copyright).to eq("© 2021 Example")
    end
  end
end
