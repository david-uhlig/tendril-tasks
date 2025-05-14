require "rails_helper"

RSpec.describe Gustwave::AvatarText, type: :component do
  with_options selector: "div" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  it "wraps the text argument in a span tag" do
    render_inline(described_class.new("AB"))
    expect(rendered_content).to have_css("span", text: "AB")
  end

  it "renders base styling" do
    render_inline(described_class.new("AB"))
    expect(rendered_content).to have_css("div.bg-gray-100") # base avatar styling
  end

  it "applies text size class according to the given size" do
    render_inline(described_class.new("CD", size: :xl))

    expect(rendered_content).to have_css("span.text-xl", text: "CD")
  end

  it "renders with different scheme if provided" do
    render_inline(described_class.new("GH", scheme: :square))

    expect(rendered_content).to have_css("div.rounded")
    expect(rendered_content).to include("GH")
  end

  it "renders a border when border is true" do
    render_inline(described_class.new("IJ", size: :md, border: true))

    expect(rendered_content).to have_css("div.ring-2")
  end
end
