require "rails_helper"

RSpec.describe Gustwave::Avatar, type: :component do
  context "with a source" do
    it_behaves_like "a component with configurable html attributes", selector: "img", src: "https://example.com/avatar.png"

    it "does not pass the tag on to the image" do
      render_inline(described_class.new(src: "https://example.com/avatar.png", tag: :span))

      expect(rendered_content).not_to have_selector("img[tag]")
    end

    context "when rendered with alt text" do
      before(:each) do
        render_inline(described_class.new(src: "https://example.com/avatar.png", alt: "Jane"))
      end

      it "renders an image with the source" do
        expect(rendered_content).to have_selector("img[src='https://example.com/avatar.png']")
      end

      it "gives the image its alt text" do
        expect(rendered_content).to have_selector("img[alt='Jane']")
      end

      it "marks the image with the img role" do
        expect(rendered_content).to have_selector("img[role='img']")
      end
    end
  end

  context "with a block" do
    it_behaves_like "a component with configurable html attributes", selector: "div"

    it "wraps the block in a div" do
      render_inline(described_class.new) { "AB" }

      expect(rendered_content).to have_selector("div.rounded-full.w-10.h-10", text: "AB")
    end

    it "wraps the block in the given tag" do
      render_inline(described_class.new(tag: :span)) { "AB" }

      expect(rendered_content).to have_selector("span.rounded-full.w-10.h-10", text: "AB")
      expect(rendered_content).not_to have_selector("div")
    end

    it "renders a square shape" do
      render_inline(described_class.new(shape: :square)) { "AB" }

      expect(rendered_content).to have_selector("div.rounded-sm", text: "AB")
    end

    it "renders a large size" do
      render_inline(described_class.new(size: :lg)) { "AB" }

      expect(rendered_content).to have_selector("div.w-12", text: "AB")
    end

    it "renders a border" do
      render_inline(described_class.new(border: true)) { "AB" }

      expect(rendered_content).to have_selector("div.ring-2", text: "AB")
    end
  end
end
