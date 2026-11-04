require "rails_helper"

RSpec.describe Modal::FooterComponent, type: :component do
  it "renders a single column grid without a medium breakpoint" do
    render_inline(described_class.new) { "Footer" }

    expect(page).to have_css("div.grid.grid-cols-1", text: "Footer")
    expect(page).to have_no_css("div[class*='md:grid-cols']")
  end

  it "renders the given number of columns from md up" do
    render_inline(described_class.new(columns: 2)) { "Footer" }

    expect(page).to have_css("div.grid.grid-cols-1.md\\:grid-cols-2", text: "Footer")
  end

  it "merges a caller class" do
    render_inline(described_class.new(columns: 2, class: "mt-2")) { "Footer" }

    expect(page).to have_css("div.md\\:grid-cols-2.mt-2.grid-cols-1")
  end

  it "renders the block content" do
    render_inline(described_class.new) { "<button>Save</button>".html_safe }

    expect(page).to have_button("Save")
  end
end
