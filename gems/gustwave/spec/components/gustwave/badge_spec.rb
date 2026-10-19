# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Badge, type: :component do
  context "without text or content" do
    it "renders an empty badge" do
      render_inline(described_class.new)

      expect(page).to have_selector("span.rounded-full", exact_text: "")
    end
  end

  context "with a tag" do
    it "renders a div" do
      render_inline(described_class.new(tag: :div)) { "content" }

      expect(page).to have_selector("div", exact_text: "content")
    end

    it "renders the hover style for links and buttons only" do
      render_inline(described_class.new(tag: :a, href: "#")) { "content" }
      expect(page).to have_selector("a[class*='hover:']")

      render_inline(described_class.new(tag: :button)) { "content" }
      expect(page).to have_selector("button[class*='hover:']")

      render_inline(described_class.new(tag: :span)) { "content" }
      expect(page).not_to have_selector("[class*='hover:']")

      render_inline(described_class.new(tag: :div)) { "content" }
      expect(page).not_to have_selector("[class*='hover:']")
    end

    it "raises for an unsupported tag" do
      expect { render_inline(described_class.new(tag: :p)) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :p for :tag/)
    end
  end

  context "with a type" do
    it "renders no type attribute by default" do
      render_inline(described_class.new) { "content" }

      expect(page).not_to have_selector("[type]")
    end

    it "renders the type of any tag" do
      render_inline(described_class.new(tag: :span, type: :submit)) { "content" }

      expect(page).to have_selector("span[type='submit']")
    end

    it "raises for an unsupported type" do
      expect { render_inline(described_class.new(type: :link)) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :link for :type/)
    end
  end

  context "with text" do
    it "renders the text" do
      render_inline(described_class.new("text"))
      expect(page).to have_content("text")
    end

    it "renders the text when content is given" do
      render_inline(described_class.new("text").with_content("content"))
      expect(page).to have_content("text")
    end
  end

  context "with content" do
    it "renders the content" do
      render_inline(described_class.new.with_content("content"))
      expect(page).to have_content("content")
    end
  end

  context "with border" do
    it "casts a string to a boolean" do
      render_inline(described_class.new(border: "true", outline: "false"))
      expect(page).to have_selector("span.border.border-blue-400")
      expect(page).not_to have_selector("span.outline")
    end
  end

  context "with options" do
    it "renders additional classes" do
      render_inline(described_class.new(class: "some-additional-css-class"))
      expect(page).to have_selector("span.some-additional-css-class")
    end

    it "renders html attributes" do
      render_inline(described_class.new(id: "some-id", lang: "de"))
      expect(rendered_content).to have_selector("span[id='some-id']")
      expect(rendered_content).to have_selector("span[lang='de']")
    end
  end

  context "with a dismiss button" do
    it_behaves_like "a component with a dismiss button slot", "New", id_prefix: "badge"

    it "renders an inline button that dismisses the badge" do
      render_inline(described_class.new("New", id: "badge-new"), &:with_dismiss_button)

      expect(page).to have_selector("span#badge-new > button[type='button'][aria-label='Dismiss'][data-dismiss-target='#badge-new']")
      expect(page).to have_selector("button > svg[aria-hidden='true']")
      expect(page).to have_selector("button > span.sr-only", text: "Dismiss")
    end
  end
end
