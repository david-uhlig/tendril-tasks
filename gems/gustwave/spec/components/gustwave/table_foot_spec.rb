require "rails_helper"

RSpec.describe Gustwave::TableFoot, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "tfoot"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with row slotted content" do
    it "renders a tr with the exact footer classes" do
      render_inline(described_class.new) do |component|
        component.with_row
      end
      tr = Capybara.string(rendered_content).find("tfoot tr")
      expect(tr[:class]).to eq("font-semibold text-gray-900 dark:text-white")
    end

    it "renders a th with scope row, text-base and py-3 when using with_cell_th" do
      render_inline(described_class.new) do |component|
        row = component.with_row
        row.with_cell_th { "cell_content" }
      end
      th = Capybara.string(rendered_content).find("tfoot th")
      expect(th[:class]).to eq("px-6 py-3 text-base")
      expect(th[:scope]).to eq("row")
      expect(th.text).to eq("cell_content")
    end

    it "renders a td with exact px-6 py-3 classes when using with_cell_td" do
      render_inline(described_class.new) do |component|
        row = component.with_row
        row.with_cell_td { "cell_content" }
      end
      td = Capybara.string(rendered_content).find("tfoot td")
      expect(td[:class]).to eq("px-6 py-3")
      expect(td.text).to eq("cell_content")
    end

    it "does not use py-4 padding on cells" do
      render_inline(described_class.new) do |component|
        row = component.with_row
        row.with_cell_th { "Total" }
        row.with_cell_td { "3" }
      end
      expect(rendered_content).not_to include("py-4")
    end

    it "renders the text and custom classes of a td cell" do
      render_inline(described_class.new) do |component|
        row = component.with_row
        row.with_cell_td "3", class: "custom"
      end
      expect(rendered_content).to have_selector("td.px-6.py-3.custom", text: "3")
    end
  end

  context "with block content" do
    it "renders block content after the rows" do
      render_inline(described_class.new) do |component|
        row = component.with_row
        row.with_cell_th { "Total" }
        "<tr><td>block_content</td></tr>".html_safe
      end
      expect(rendered_content).to match(/Total.*block_content/)
    end
  end
end
