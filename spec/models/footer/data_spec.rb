require 'rails_helper'

RSpec.describe Footer::Data, type: :model do
  let(:data) { described_class.new }

  describe "#updated_at" do
    context "when there are no settings and pages" do
      it "returns nil" do
        expect(data.updated_at).to be_nil
      end
    end

    context "when there are settings and no pages" do
      let(:setting1) { create(:setting) }
      let(:setting2) { create(:setting) }

      it "returns the maximum updated_at of Setting" do
        latest_update = [ setting1.updated_at, setting2.updated_at ].max
        expect(data.updated_at).to eq(latest_update)
      end
    end

    context "when there are pages and no settings" do
      let(:imprint_page) { create(:page, slug: "imprint") }
      let(:other_page) { create(:page, slug: "other") }

      it "returns the maximum updated_at of Page" do
        latest_update = [ imprint_page.updated_at, other_page.updated_at ].max
        expect(data.updated_at).to eq(latest_update)
      end
    end

    context "when there are pages and settings" do
      let(:setting1) { create(:setting) }
      let(:imprint_page) { create(:page, slug: "imprint") }
      let(:other_page) { create(:page, slug: "other") }

      it "returns the maximum updated_at of Setting and Page" do
        latest_update = [ setting1.updated_at, imprint_page.updated_at, other_page.updated_at ].max
        expect(data.updated_at).to eq(latest_update)
      end
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
    it "returns an empty hash when there is no footer sitemap" do
      expect(data.sitemap).to eq({})
    end

    it "returns the categories of the footer sitemap" do
      sitemap = { "categories" =>
                   [ { "title" => "Gehe zu", "links" => [ { "title" => "Start", "href" => "/" }, { "title" => "Themen", "href" => "/projects" }, { "title" => "Aufgaben", "href" => "/tasks" } ] },
                    { "title" => "Example Apps",
                     "links" => [ { "title" => "Chat", "href" => "https://example.com" }, { "title" => "Homepage", "href" => "https://example.com/home" }, { "title" => "Terminplaner", "href" => "https://example.com/calendar" } ] } ] }
      categories = [ { "title" => "Gehe zu", "links" => [ { "title" => "Start", "href" => "/" }, { "title" => "Themen", "href" => "/projects" }, { "title" => "Aufgaben", "href" => "/tasks" } ] },
                    { "title" => "Example Apps",
                     "links" => [ { "title" => "Chat", "href" => "https://example.com" }, { "title" => "Homepage", "href" => "https://example.com/home" }, { "title" => "Terminplaner", "href" => "https://example.com/calendar" } ] } ]
      create(:setting, key: "footer_sitemap", value: sitemap)

      expect(data.sitemap).to eq(categories)
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
