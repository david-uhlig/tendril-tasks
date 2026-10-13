require "rails_helper"

RSpec.describe Gustwave::Buttons::Base, type: :component do
  with_options selector: "button[type='button']" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default tag with default type" do
      expect(rendered_content).to have_selector("button[type='button']")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("button.rounded-lg.text-center.overflow-hidden.whitespace-nowrap.align-bottom")
    end

    it "renders default size styling" do
      expect(rendered_content).to have_selector("button.px-5.text-sm.font-medium")
    end

    it "renders no pill styling" do
      expect(rendered_content).not_to have_selector("button.rounded-full")
    end

    it "renders no leading/trailing visual styling" do
      expect(rendered_content).not_to have_selector("button.inline-flex.items-center.align-bottom")
    end
  end

  context "with tag argument" do
    before(:context) do
      render_inline(described_class.new(tag: :a)) { "anchor_content" }
    end

    it "renders an anchor tag" do
      expect(rendered_content).to have_selector("a", text: "anchor_content")
    end

    it "render no type attribute when tag is set to :a" do
      expect(rendered_content).not_to have_selector("a[type]")
    end
  end

  context "with scheme argument" do
    it "renders no base styling when scheme is set to :none" do
      render_inline(described_class.new(scheme: :none)) { "content" }
      expect(rendered_content).not_to have_selector("button.rounded-lg")
      expect(rendered_content).not_to have_selector("button.text-center")
      expect(rendered_content).not_to have_selector("button.overflow-hidden")
    end

    it "renders base styling when scheme is set to :base" do
      render_inline(described_class.new(scheme: :base)) { "content" }
      expect(rendered_content).to have_selector("button.rounded-lg.text-center.overflow-hidden.whitespace-nowrap.align-bottom")
    end
  end

  context "with size argument" do
    it "renders custom size styling" do
      render_inline(described_class.new(size: :xl)) { "content" }
      expect(rendered_content).to have_selector("button.px-6.text-base.font-medium")
    end
  end

  context "with pill argument" do
    it "renders pill styling" do
      render_inline(described_class.new(pill: true)) { "content" }
      expect(rendered_content).to have_selector("button.rounded-full")
    end
  end

  context "with leading visual" do
    it "renders leading visual classes" do
      render_inline(described_class.new) do |component|
        component.leading_icon :dismiss
      end
      expect(rendered_content).to have_selector("button.inline-flex.items-center.align-bottom")
    end

    it "renders leading visual icon" do
      render_inline(described_class.new) do |component|
        component.leading_icon :dismiss
      end
      expect(rendered_content).to have_selector("button>svg")
    end

    it "renders leading visual image" do
      render_inline(described_class.new) do |component|
        component.leading_image "https://example.com/image.png"
      end
      expect(rendered_content).to have_selector("button>img[src='https://example.com/image.png']")
    end

    it "renders leading visual svg" do
      render_inline(described_class.new) do |component|
        component.leading_svg "https://example.com/svg.svg"
      end
      expect(rendered_content).to have_selector("button>svg")
    end
  end

  context "with trailing visual" do
    it "renders trailing visual classes" do
      render_inline(described_class.new) do |component|
        component.trailing_icon :dismiss
      end
      expect(rendered_content).to have_selector("button.inline-flex.items-center.align-bottom")
    end

    it "renders trailing visual icon" do
      render_inline(described_class.new) do |component|
        component.trailing_icon :dismiss
      end
      expect(rendered_content).to have_selector("button>svg")
    end

    it "renders trailing visual image" do
      render_inline(described_class.new) do |component|
        component.trailing_image "https://example.com/image.png"
      end
      expect(rendered_content).to have_selector("button>img[src='https://example.com/image.png']")
    end

    it "renders trailing visual svg" do
      render_inline(described_class.new) do |component|
        component.trailing_svg "https://example.com/svg.svg"
      end
      expect(rendered_content).to have_selector("button>svg")
    end
  end

  context "with leading visual without content" do
    it "overwrites padding" do
      render_inline(described_class.new) do |component|
        component.leading_icon :dismiss
      end
      expect(rendered_content).to have_selector('button.p-2\.5')
    end
  end
end
