require "rails_helper"

RSpec.describe Gustwave::TableCell, type: :component do
  with_options selector: "td" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("td.px-6.py-4")
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
end
