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
    it "renders a td tag with content when using the cell slot alias" do
      render_inline(described_class.new) do |component|
        component.cell { "cell_content" }
      end
      expect(rendered_content).to have_selector("td.px-6.py-4", text: "cell_content")
    end

    it "renders a td tag with content when using the td slot alias" do
      render_inline(described_class.new) do |component|
        component.td { "cell_content" }
      end
      expect(rendered_content).to have_selector("td.px-6.py-4", text: "cell_content")
    end

    it "renders a th tag with content when using the head slot alias" do
      render_inline(described_class.new) do |component|
        component.head { "cell_content" }
      end
      expect(rendered_content).to have_selector("th.px-6.py-4", text: "cell_content")
      expect(rendered_content).to have_selector("th[scope='row']")
    end

    it "renders a th tag with content when using the th slot alias" do
      render_inline(described_class.new) do |component|
        component.th { "cell_content" }
      end
      expect(rendered_content).to have_selector("th.px-6.py-4", text: "cell_content")
      expect(rendered_content).to have_selector("th[scope='row']")
    end
  end

  context "with cell slot and block content" do
    it "appends block content after the cell slot content" do
      render_inline(described_class.new) do |component|
        component.cell { "cell_content" }
        "<td>block_content</td>".html_safe
      end
      expect(rendered_content).to have_selector("td.px-6.py-4", text: "cell_content")
      expect(rendered_content).to have_selector("td", text: "block_content")
      expect(rendered_content).to match(/cell_content.*block_content/)
    end
  end
end
