require "rails_helper"

RSpec.describe Gustwave::Avatar, type: :component do
  it "renders an image with a source" do
    render_inline(described_class.new(src: "https://example.com/avatar.png", tag: :span))

    expect(rendered_content).to have_selector("img[src='https://example.com/avatar.png']")
    expect(rendered_content).not_to have_selector("img[tag]")
  end

  it "wraps the block in a div without a source" do
    render_inline(described_class.new) { "AB" }

    expect(rendered_content).to have_selector("div.rounded-full.w-10.h-10", text: "AB")
  end

  it "wraps the block in the given tag without a source" do
    render_inline(described_class.new(tag: :span)) { "AB" }

    expect(rendered_content).to have_selector("span.rounded-full.w-10.h-10", text: "AB")
    expect(rendered_content).not_to have_selector("div")
  end
end
