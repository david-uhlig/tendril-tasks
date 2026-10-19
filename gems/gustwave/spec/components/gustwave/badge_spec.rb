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
      expect(page).not_to have_selector("[class~='border']")
      expect(page).not_to have_selector("[class*='border-']")
    end
  end

  context "without text or content" do
    it "renders an empty badge" do
      render_inline(described_class.new)

      expect(page).to have_selector("span.rounded-full", exact_text: "")
    end
  end

  context "with a tag" do
    it "renders a div" do
      render_inline(described_class.new(tag: :div)) { "content" }

      expect(page).to have_selector("div.rounded-sm")
    end

    it "renders the hover style for a link" do
      render_inline(described_class.new(tag: :a, href: "#")) { "content" }

      expect(page).to have_selector("a.hover\\:bg-blue-200")
    end

    it "renders the hover style for a button" do
      render_inline(described_class.new(tag: :button)) { "content" }

      expect(page).to have_selector("button.hover\\:bg-blue-200")
    end

    it "renders no hover style for a span" do
      render_inline(described_class.new(tag: :span)) { "content" }

      expect(page).not_to have_selector("[class*='hover:']")
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
  end

  context "with text" do
    it "renders the text" do
      render_inline(described_class.new("text"))
      expect(page).to have_content("text")
    end

    it "renders only the text when content is given" do
      render_inline(described_class.new("text").with_content("content"))
      expect(page).to have_content("text")
      expect(page).not_to have_content("content")
    end
  end

  context "with content" do
    it "renders the content" do
      render_inline(described_class.new.with_content("content"))
      expect(page).to have_content("content")
    end
  end

  context "with pill" do
    it "renders rounded corners for a pill" do
      render_inline(described_class.new("New", pill: true))
      expect(page).to have_selector("span.rounded-full", text: "New")
    end

    it "renders square corners by default" do
      render_inline(described_class.new("New"))
      expect(page).to have_selector("span.rounded-sm", text: "New")
      expect(page).not_to have_selector("span.rounded-full")
    end
  end

  context "with color" do
    it "renders color classes" do
      render_inline(described_class.new(color: :purple))
      expect(page).to have_selector("span.bg-purple-100.text-purple-800")
    end

    it "renders no base or color styles for color :none" do
      render_inline(described_class.new("New", color: :none))
      expect(page).to have_selector("span", text: "New")
      expect(page).not_to have_selector("span.rounded-sm")
      expect(page).not_to have_selector("span.inline-flex")
      expect(page).not_to have_selector("[class*='bg-']")
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

    it "sizes a leading indicator to match the badge size" do
      render_inline(described_class.new("New", size: :xl)) { |badge| badge.with_leading_visual_indicator }
      expect(page).to have_selector("span > span.h-6")

      render_inline(described_class.new("New")) { |badge| badge.with_leading_visual_indicator }
      expect(page).to have_selector("span > span.h-3")
    end
  end

  context "with border" do
    it "render border classes" do
      render_inline(described_class.new(border: true))
      expect(page).to have_selector("span.border.border-blue-400")
    end

    it "renders outline classes" do
      render_inline(described_class.new(outline: true))
      expect(page).to have_selector("span.outline-blue-400")
    end

    it "casts a string to a boolean" do
      render_inline(described_class.new(border: "true", outline: "false"))
      expect(page).to have_selector("span.border.border-blue-400")
      expect(page).not_to have_selector("span.outline-blue-400")
    end
  end

  context "with options" do
    it_behaves_like "a component with configurable html attributes", selector: "span"
  end

  context "with leading and trailing visuals and a dismiss button" do
    it "renders them in order around the text" do
      render_inline(described_class.new("New", id: "badge-new")) do |badge|
        badge.with_leading_visual_image "https://example.com/leading.png", alt: "Lead"
        badge.with_trailing_visual_icon :close
        badge.with_dismiss_button
      end

      children = Nokogiri::HTML.fragment(rendered_content).at_css("span#badge-new").children
      expect(children.filter_map { it.element? ? it.name : it.text.strip.presence }).to eq %w[img New svg button]
    end
  end

  context "with a dismiss button" do
    it_behaves_like "a component with a dismiss button slot", "New", id_prefix: "badge"

    it "renders a dismiss button with a small icon" do
      render_inline(described_class.new("New", id: "badge-new"), &:with_dismiss_button)

      expect(page).to have_selector("button.bg-transparent > svg.h-3[aria-hidden='true']")
    end

    it "matches the badge's color and size" do
      render_inline(described_class.new("New", color: :pink, size: :"2xl"), &:with_dismiss_button)

      expect(page).to have_selector("button.text-pink-400.hover\\:bg-pink-200.p-2 > svg.h-4")
    end
  end
end
