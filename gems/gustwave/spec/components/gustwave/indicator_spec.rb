require "rails_helper"

RSpec.describe Gustwave::Indicator, type: :component do
  with_options selector: "span" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before do
      render_inline(described_class.new)
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("span.rounded-full")
    end

    it "renders size styling" do
      expect(rendered_content).to have_selector("span.h-3.min-w-3")
    end

    it "renders color styling" do
      expect(rendered_content).to have_selector("span.bg-gray-200")
    end
  end

  context "with custom size" do
    it "renders custom size styling" do
      render_inline(described_class.new(size: :lg))
      expect(rendered_content).to have_selector("span.h-4")
    end
  end

  context "with auto size" do
    it "matches the line height" do
      render_inline(described_class.new(size: :auto))
      expect(rendered_content).to have_selector('span.h-\[1em\]')
    end
  end

  {
    xs: "h-2\\.5.min-w-2\\.5",
    sm: "h-3.min-w-3",
    md: "h-3\\.5.min-w-3\\.5",
    lg: "h-4.min-w-4",
    xl: "h-6.min-w-6",
    "2xl": "h-8.min-w-8"
  }.each do |size, classes|
    it "renders the #{size} scale" do
      render_inline(described_class.new(size:))
      expect(rendered_content).to have_selector("span.#{classes}")
    end
  end

  context "with pulse" do
    it "renders pulse styling" do
      render_inline(described_class.new(pulse: true))
      expect(rendered_content).to have_selector("span.animate-pulse")
    end
  end

  context "with custom color" do
    it "renders color styling" do
      render_inline(described_class.new(color: :red))
      expect(rendered_content).to have_selector("span.bg-red-500")
    end
  end

  context "with custom position" do
    it "renders position styling" do
      render_inline(described_class.new(position: :top_left))
      expect(rendered_content).to have_selector("span.absolute.top-0.left-0")
    end
  end

  context "with block content" do
    before do
      render_inline(described_class.new) { "content" }
    end

    it "renders text styling" do
      expect(rendered_content).to have_selector("span.text-white")
    end
  end

  context "with legend slot" do
    before do
      render_inline(described_class.new) do |component|
        component.with_legend { "legend_content" }
      end
    end

    it "wraps indicator in legend" do
      expect(rendered_content).to have_selector("span>span")
      expect(rendered_content).to have_selector("span", text: "legend_content")
    end

    it "renders legend styling" do
      expect(rendered_content).to have_selector("span.text-sm")
    end
  end
end
