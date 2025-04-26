require "rails_helper"

RSpec.describe Gustwave::TableCell, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("td.px-6.py-4")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with custom tag" do
    it "renders the th tag when tag is :th" do
      render_inline(described_class.new(tag: :th)) { "content" }
      expect(rendered_content).to have_selector("th")
      expect(rendered_content).not_to have_selector("td")
    end
  end

  context "with custom classes" do
    it "merges additional classes with base styles" do
      render_inline(described_class.new(class: "text-red-500")) { "content" }
      expect(rendered_content).to have_selector("td.text-red-500.px-6.py-4")
    end

    it "overrides base styles with additional classes" do
      render_inline(described_class.new(class: "px-0 py-0")) { "content" }
      expect(rendered_content).to have_selector("td.px-0.py-0")
    end
  end

  context "with custom HTML attributes" do
    it "adds additional attributes to the HTML tag" do
      render_inline(described_class.new(scope: "row")) { "content" }
      expect(rendered_content).to have_selector("td[scope='row']")
    end
  end

  context "with text" do
    it "renders text" do
      render_inline(described_class.new("text_content"))
      expect(rendered_content).to have_content("text_content")
    end

    it "renders text when block content and text are given" do
      render_inline(described_class.new("text_content")) { "block_content" }
      expect(rendered_content).to have_content("text_content")
      expect(rendered_content).not_to have_content("block_content")
    end
  end
end
