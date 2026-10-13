require "rails_helper"

RSpec.describe Gustwave::TableBody, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "tbody"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("tbody")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with row slotted content" do
    it "renders a tr tag with content when using the row slot alias" do
      render_inline(described_class.new) do |component|
        component.row { "row_content" }
      end
      expect(rendered_content).to have_selector("tr", text: "row_content")
    end

    it "renders a tr tag with content when using the tr slot alias" do
      render_inline(described_class.new) do |component|
        component.tr { "row_content" }
      end
      expect(rendered_content).to have_selector("tr", text: "row_content")
    end
  end

  context "with row slot and block content" do
    it "appends block content after the row slot content" do
      render_inline(described_class.new) do |component|
        component.row { "row_content" }
        "<tr>block_content</tr>".html_safe
      end
      expect(rendered_content).to have_selector("tr", text: "row_content")
      expect(rendered_content).to have_selector("tr", text: "block_content")
      expect(rendered_content).to match(/row_content.*block_content/)
    end
  end
end
