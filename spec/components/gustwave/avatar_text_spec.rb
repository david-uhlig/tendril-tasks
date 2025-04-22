require "rails_helper"

RSpec.describe Gustwave::AvatarText, type: :component do
  it "renders the text inside an Avatar component" do
    render_inline(described_class.new(text: "AB"))

    expect(rendered_content).to have_css("span", text: "AB")
    expect(rendered_content).to have_css("div.bg-gray-100") # base avatar styling
  end

  it "renders custom block content when text is not provided" do
    render_inline(described_class.new(size: :lg)) do
      "Custom Content"
    end

    expect(rendered_content).to include("Custom Content")
  end

  it "prioritizes text over block content" do
    render_inline(described_class.new(text: "XY")) do
      "Ignored Block"
    end

    expect(rendered_content).to include("XY")
    expect(rendered_content).not_to include("Ignored Block")
  end

  it "applies text size class according to the given size" do
    render_inline(described_class.new(text: "CD", size: :xl))

    expect(rendered_content).to have_css("span.text-xl", text: "CD")
  end

  it "merges additional classes into avatar container" do
    render_inline(described_class.new(text: "EF", class: "rounded-full"))

    expect(rendered_content).to have_css("div.rounded-full")
  end

  it "renders with different scheme if provided" do
    render_inline(described_class.new(text: "GH", scheme: :square))

    expect(rendered_content).to have_css("div.rounded")
    expect(rendered_content).to include("GH")
  end

  it "renders a border when border is true" do
    render_inline(described_class.new(text: "IJ", size: :md, border: true))

    expect(rendered_content).to have_css("div.ring-2")
  end
end
