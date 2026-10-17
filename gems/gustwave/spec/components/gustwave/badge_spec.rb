# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Badge, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styles" do
      expect(rendered_content).to have_selector("span.rounded-sm.whitespace-nowrap.inline-flex")
    end

    it "renders default size classes" do
      expect(page).to have_selector("span.text-xs.font-medium")
    end

    it "renders no border classes" do
      expect(page).not_to have_selector("span.border.border-blue-400")
    end

    it "renders no content" do
      expect(page).to have_text("")
    end
  end

  context "with a tag" do
    it "renders a div" do
      render_inline(described_class.new(tag: :div)) { "content" }

      expect(page).to have_selector("div.rounded-sm")
    end

    it "renders the hover style for links and buttons only" do
      render_inline(described_class.new(tag: :a, href: "#")) { "content" }
      expect(page).to have_selector("a.hover\\:bg-blue-200")

      render_inline(described_class.new(tag: :span)) { "content" }
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

  context "with color" do
    it "renders color classes" do
      render_inline(described_class.new(color: :purple))
      expect(page).to have_selector("span.bg-purple-100.text-purple-800")
    end
  end

  context "with size" do
    it "renders size classes" do
      render_inline(described_class.new(size: :lg))
      expect(page).to have_selector("span.text-lg.font-semibold")
    end

    it "renders a round badge without text or content at any size" do
      render_inline(described_class.new(size: :"2xl")) { |badge| badge.with_leading_visual_icon(:check) }
      expect(page).to have_selector("span.rounded-full.px-0\\.5")
    end
  end

  context "with border" do
    it "render border classes" do
      render_inline(described_class.new(border: true))
      expect(page).to have_selector("span.border.border-blue-400")
    end

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
    it "renders an inline button that dismisses the badge" do
      render_inline(described_class.new("New", id: "badge-new"), &:with_dismiss_button)

      expect(page).to have_selector("span#badge-new > button[type='button'][aria-label='remove'][data-dismiss-target='#badge-new']")
      expect(page).to have_selector("button.bg-transparent.text-blue-400.p-1 > svg.h-3[aria-hidden='true']")
      expect(page).to have_selector("button > span.sr-only", text: "Dismiss")
    end

    it "matches the badge's color and size" do
      render_inline(described_class.new("New", color: :pink, size: :"2xl"), &:with_dismiss_button)

      expect(page).to have_selector("button.text-pink-400.hover\\:bg-pink-200.p-2 > svg.h-4")
    end

    it "uses a custom label" do
      render_inline(described_class.new("New")) { |badge| badge.with_dismiss_button("Remove filter") }

      expect(page).to have_selector("button > span.sr-only", text: "Remove filter")
    end
  end
end
