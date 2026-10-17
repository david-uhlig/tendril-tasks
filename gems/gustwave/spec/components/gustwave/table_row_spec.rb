require "rails_helper"

RSpec.describe Gustwave::TableRow, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "tr"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("tr.border-b.border-gray-200.bg-white")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with cell slotted content" do
    it "renders a td tag with content when using the with_cell_td setter" do
      render_inline(described_class.new) do |component|
        component.with_cell_td { "cell_content" }
      end
      expect(rendered_content).to have_selector("td.px-6.py-4", text: "cell_content")
    end

    it "renders a th tag with content when using the with_cell_th setter" do
      render_inline(described_class.new) do |component|
        component.with_cell_th { "cell_content" }
      end
      expect(rendered_content).to have_selector("th.px-6.py-4", text: "cell_content")
      expect(rendered_content).to have_selector("th[scope='row']")
    end
  end

  context "with cell text" do
    it "renders the text of a td cell" do
      render_inline(described_class.new) do |component|
        component.with_cell_td "cell_text", class: "custom"
      end
      expect(rendered_content).to have_selector("td.px-6.py-4.custom", text: "cell_text")
    end

    it "renders the text of a th cell" do
      render_inline(described_class.new) do |component|
        component.with_cell_th "head_text"
      end
      expect(rendered_content).to have_selector("th.px-6.py-4[scope='row']", text: "head_text")
    end

    it "prefers the text over block content" do
      render_inline(described_class.new) do |component|
        component.with_cell_td("cell_text") { "block_text" }
      end
      expect(rendered_content).to have_selector("td", text: "cell_text")
      expect(rendered_content).not_to have_content("block_text")
    end
  end

  context "with cell slot and block content" do
    it "appends block content after the cell slot content" do
      render_inline(described_class.new) do |component|
        component.with_cell_td { "cell_content" }
        "<td>block_content</td>".html_safe
      end
      expect(rendered_content).to have_selector("td.px-6.py-4", text: "cell_content")
      expect(rendered_content).to have_selector("td", text: "block_content")
      expect(rendered_content).to match(/cell_content.*block_content/)
    end
  end
end
