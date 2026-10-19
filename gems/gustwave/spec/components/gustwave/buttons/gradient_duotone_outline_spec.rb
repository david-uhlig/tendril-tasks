require "rails_helper"

RSpec.describe Gustwave::Buttons::GradientDuotoneOutline, type: :component do
  it_behaves_like "a button theme"

  it "renders text without visuals" do
    render_inline(described_class.new("Save"))

    expect(rendered_content).to have_selector("button span", text: "Save")
  end

  it "renders leading and trailing visuals around the text" do
    render_inline(described_class.new("Save")) do |component|
      component.with_leading_visual_icon :dismiss
      component.with_trailing_visual_indicator "3"
    end

    inner = page.find("button > span")
    expect(inner).to have_selector("svg")
    expect(inner).to have_text("3")
    expect(inner.text).to match(/Save.*3/m)
  end

  it "forwards the tag to the button" do
    render_inline(described_class.new("Go", tag: :a, href: "#"))

    expect(page).to have_selector("a[href='#'] > span", text: "Go")
  end

  it "forwards the type to the button" do
    render_inline(described_class.new("Go", type: :submit))

    expect(page).to have_selector("button[type='submit'] > span", text: "Go")
  end

  it "forwards the pill shape to the button" do
    render_inline(described_class.new("Go", pill: true))

    expect(page).to have_selector("button.rounded-full > span", text: "Go")
  end

  it "squares the inner part of an icon-only button" do
    render_inline(described_class.new) { |button| button.with_leading_visual_icon :check }

    expect(page).to have_selector("button > span.p-2\\.5")
  end

  it "sizes the inner part for the size option" do
    render_inline(described_class.new("Go", size: :xl))

    expect(page).to have_selector("button > span.px-6", text: "Go")
    expect(page).not_to have_selector("button.px-6")
  end
end
