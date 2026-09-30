# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::RichText, type: :component do
  def root_element
    Nokogiri::HTML.fragment(rendered_content).element_children.first
  end

  describe "default rendering" do
    before do
      render_inline(described_class.new) { "content" }
    end

    it "renders the main content" do
      expect(page).to have_text("content")
    end

    it "renders a div as the root element" do
      expect(root_element.name).to eq("div")
    end

    it "renders the base classes on the root element" do
      expect(root_element["class"].split).to include("*:hyphens-auto")
    end

    it "renders the lang attribute with the default locale" do
      expect(root_element["lang"]).to eq(I18n.default_locale.to_s)
    end

    it "renders block content inside the root element" do
      expect(root_element.text).to include("content")
    end
  end

  describe "content rendering" do
    it "renders a string passed to the initializer" do
      render_inline(described_class.new("Provided content"))

      expect(page).to have_text("Provided content")
    end

    it "preserves supported rich text formatting" do
      render_inline(
        described_class.new("<p>Hello <strong>world</strong></p>")
      )

      expect(page).to have_css("p", text: "Hello world")
      expect(page).to have_css("p strong", text: "world")
    end

    it "preserves the order of nested content" do
      render_inline(
        described_class.new("<p>First paragraph</p><p>Second paragraph</p>")
      )

      expect(page.all("p").map(&:text)).to eq(
                                             [ "First paragraph", "Second paragraph" ]
                                           )
    end

    it "renders links with their text and URL" do
      render_inline(
        described_class.new(
          '<p><a href="https://example.com/docs">Read the docs</a></p>'
        )
      )

      expect(page).to have_link(
                        "Read the docs",
                        href: "https://example.com/docs"
                      )
    end

    it "renders ActionText::RichText content" do
      rich_text = ActionText::RichText.new(
        body: "<p>Hello <strong>world</strong></p>"
      )

      render_inline(described_class.new(rich_text))

      expect(page).to have_css("p", text: "Hello world")
      expect(page).to have_css("strong", text: "world")
    end

    it "renders an empty wrapper when no content is provided" do
      render_inline(described_class.new)

      expect(root_element.name).to eq("div")
      expect(root_element.text.strip).to be_empty
    end

    it "renders an empty wrapper for an empty string" do
      render_inline(described_class.new(""))

      expect(root_element.name).to eq("div")
      expect(root_element.text.strip).to be_empty
    end
  end

  describe "HTML attributes" do
    it "adds custom classes without removing the base classes" do
      render_inline(described_class.new("content", class: "custom-rich-text"))

      expect(root_element["class"].split).to include(
                                               "*:hyphens-auto",
                                               "custom-rich-text"
                                             )
    end

    it "uses an explicitly provided language" do
      render_inline(described_class.new("Bonjour", lang: "fr"))

      expect(root_element["lang"]).to eq("fr")
    end

    it "uses the default locale rather than the current locale" do
      other_locale = I18n.available_locales.find do |locale|
        locale.to_s != I18n.default_locale.to_s
      end
      skip "Requires a configured non-default locale" unless other_locale

      I18n.with_locale(other_locale) do
        render_inline(described_class.new("content"))

        expect(root_element["lang"]).to eq(I18n.default_locale.to_s)
      end
    end

    it "passes HTML and accessibility attributes to the root element" do
      render_inline(
        described_class.new(
          "content",
          id: "article-body",
          role: "region",
          aria: { label: "Article content" },
          data: { testid: "rich-text" }
        )
      )

      expect(root_element["id"]).to eq("article-body")
      expect(root_element["role"]).to eq("region")
      expect(root_element["aria-label"]).to eq("Article content")
      expect(root_element["data-testid"]).to eq("rich-text")
    end
  end

  describe "HTML safety" do
    it "sanitizes unsafe HTML while preserving supported content" do
      render_inline(
        described_class.new(
          '<p onclick="alert(1)">Safe <strong>content</strong></p>' \
            "<script>alert(1)</script>"
        )
      )

      expect(page).to have_css("p strong", text: "content")
      expect(page).not_to have_css("script", visible: :all)
      expect(page).not_to have_css("[onclick]", visible: :all)
    end

    it "renders escaped markup as text rather than an HTML element" do
      render_inline(
        described_class.new("<p>&lt;strong&gt;Literal&lt;/strong&gt;</p>")
      )

      expect(page).to have_text("<strong>Literal</strong>")
      expect(page).not_to have_css("strong")
    end
  end
end
