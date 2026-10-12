# frozen_string_literal: true

require "rails_helper"

RSpec.describe Text::Highlight::GradientComponent, type: :component do
  it "highlights the part of the text" do
    render_inline(described_class.new("Get actively involved!", highlight: "actively"))

    expect(page).to have_text("Get actively involved!")
    expect(page).to have_css("span.bg-clip-text", text: "actively", exact_text: true)
  end

  it "shows the text without a highlight when there is none" do
    render_inline(described_class.new("Get involved!", highlight: nil))

    expect(page).to have_text("Get involved!")
    expect(page).not_to have_css("span")
  end

  it "escapes the text and the highlight" do
    render_inline(described_class.new("<b>Fish & Chips</b>", highlight: "& Chips"))

    expect(page).not_to have_css("b")
    expect(page).to have_text("<b>Fish & Chips</b>")
    expect(page).to have_css("span", text: "& Chips", exact_text: true)
  end
end
