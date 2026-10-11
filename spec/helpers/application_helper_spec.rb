require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#document_title" do
    it "shows the site name and the default tagline in the current language" do
      I18n.with_locale(:en) do
        expect(helper.document_title).to eq("Tendril Tasks - growing beyond ourselves together")
      end
      I18n.with_locale(:de) do
        expect(helper.document_title).to eq("Tendril Tasks - gemeinsam über uns hinauswachsen")
      end
    end

    it "shows a tagline of its own in every language" do
      Site.create!(name: "Acme", tagline: "for everyone")

      I18n.with_locale(:en) do
        expect(helper.document_title).to eq("Acme - for everyone")
      end
      I18n.with_locale(:de) do
        expect(helper.document_title).to eq("Acme - for everyone")
      end
    end

    it "shows the title of the page before the site name" do
      Site.create!(name: "Acme", tagline: "for everyone")
      helper.content_for(:title, "Gardening day")

      expect(helper.document_title).to eq("Gardening day - Acme")
    end

    it "escapes the title of the page and the site name once" do
      Site.create!(name: "Tom & Jerry")
      helper.content_for(:title, "Cats & Mice")

      expect(helper.document_title).to eq("Cats &amp; Mice - Tom &amp; Jerry")
      expect(helper.document_title).to be_html_safe
    end

    context "when APP_TITLE is configured" do
      before { allow(AppConfig).to receive(:title).and_return("Acme - for everyone") }

      it "replaces the title of pages without a title of their own" do
        Site.create!(name: "Tendril Tasks", tagline: "ignored")

        expect(helper.document_title).to eq("Acme - for everyone")
      end

      it "doesn't replace the title of pages with a title of their own" do
        helper.content_for(:title, "Gardening day")

        expect(helper.document_title).to eq("Gardening day - Tendril Tasks")
      end
    end
  end
end
