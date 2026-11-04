require "rails_helper"

RSpec.describe Gustwave::Buttons::Inline, type: :component do
  it_behaves_like "a button theme"

  it "renders the xs size by default" do
    render_inline(described_class.new("Go"))

    expect(rendered_content).to have_selector("button.p-1.text-xs")
  end

  it "keeps the size padding of an icon-only button" do
    render_inline(described_class.new) { |button| button.with_leading_visual_icon :check }

    expect(rendered_content).to have_selector("button.p-1")
    expect(rendered_content).not_to have_selector("button.p-2")
  end

  it "sizes the icon at md without Base's negative margin" do
    render_inline(described_class.new("Go", size: :md)) { |button| button.with_leading_visual_icon :check }

    icon_classes = page.find("button svg")["class"].split
    expect(icon_classes).to include("h-5")
    expect(icon_classes).not_to include("-mx-0.5")
  end

  it "sizes the icon at xl without Base's negative margin" do
    render_inline(described_class.new("Go", size: :xl)) { |button| button.with_leading_visual_icon :check }

    icon_classes = page.find("button svg")["class"].split
    expect(icon_classes).to include("h-7")
    expect(icon_classes).not_to include("-my-0.5")
  end

  it "sizes its visuals for the 3xs size" do
    render_inline(described_class.new("Go", size: :"3xs")) { |button| button.with_leading_visual_icon :check }

    expect(rendered_content).to have_selector("button > svg.h-3")
  end
end
