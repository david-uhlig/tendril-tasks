require "rails_helper"

RSpec.describe Gustwave::Table, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("table.w-full.text-sm.text-left.text-gray-500")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with custom classes" do
    it "merges additional classes with base styles" do
      render_inline(described_class.new(class: "custom-class")) { "content" }
      expect(rendered_content).to have_selector("table.w-full.text-sm.text-left.text-gray-500.custom-class")
    end

    it "overrides base styles with additional classes" do
      render_inline(described_class.new(class: "text-red-200")) { "content" }
      expect(rendered_content).to have_selector("table.w-full.text-sm.text-left.text-red-200")
      expect(rendered_content).not_to have_selector("table.text-gray-500")
    end
  end

  context "with custom HTML attributes" do
    it "adds additional attributes to the HTML tag" do
      render_inline(described_class.new(id: "table4911")) { "content" }
      expect(rendered_content).to have_selector("table[id='table4911']")
    end
  end

  context "with slotted content" do
    it "renders a caption tag with content when using the cell content alias" do
      render_inline(described_class.new) do |component|
        component.caption { "caption_content" }
      end
      expect(rendered_content).to have_selector("caption", text: "caption_content")
    end

    it "renders a thead tag with content when using the head slot alias" do
      render_inline(described_class.new) do |component|
        component.head { "head_content" }
      end
      expect(rendered_content).to have_selector("thead", text: "head_content")
    end

    it "renders a tbody tag with content when using the body slot alias" do
      render_inline(described_class.new) do |component|
        component.body { "body_content" }
      end
      expect(rendered_content).to have_selector("tbody", text: "body_content")
    end
  end

  context "with slotted content and block content" do
    it "appends block content after the slot content" do
      render_inline(described_class.new) do |component|
        component.caption { "caption_content" }
        component.head { "head_content" }
        component.body { "body_content" }
        "<tfoot>block_content</tfoot>".html_safe
      end
      expect(rendered_content).to have_selector("caption", text: "caption_content")
      expect(rendered_content).to have_selector("thead", text: "head_content")
      expect(rendered_content).to have_selector("tbody", text: "body_content")
      expect(rendered_content).to have_selector("tfoot", text: "block_content")
      expect(rendered_content).to match(/caption_content.*head_content.*body_content.*block_content/)
    end
  end
end
