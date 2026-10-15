require "rails_helper"

RSpec.describe Gustwave::Buttons::GradientDuotoneOutline, type: :component do
  it "renders text without visuals" do
    render_inline(described_class.new("Save"))

    expect(rendered_content).to have_selector("button span", text: "Save")
  end

  it "renders leading and trailing visuals around the text" do
    render_inline(described_class.new("Save")) do |component|
      component.leading_icon :dismiss
      component.trailing_indicator "3"
    end

    inner = page.find("button > span")
    expect(inner).to have_selector("svg")
    expect(inner).to have_text("3")
    expect(inner.text).to match(/Save.*3/m)
  end
end
