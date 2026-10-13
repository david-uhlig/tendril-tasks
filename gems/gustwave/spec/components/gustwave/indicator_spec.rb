require "rails_helper"

RSpec.describe Gustwave::Indicator, type: :component do
  with_options selector: "span" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new)
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("span.flex.rounded-full.aspect-square")
    end

    it "renders size styling" do
      expect(rendered_content).to have_selector('span.h-\[1em\].font-semibold')
    end

    it "renders scheme styling" do
      expect(rendered_content).to have_selector("span.bg-gray-200")
    end
  end

  context "with custom size" do
    it "renders custom size styling" do
      render_inline(described_class.new(size: :lg))
      expect(rendered_content).to have_selector("span.h-6.min-w-6.text-sm.font-semibold")
    end
  end

  context "with pulse" do
    it "renders pulse styling" do
      render_inline(described_class.new(pulse: true))
      expect(rendered_content).to have_selector("span.animate-pulse")
    end
  end

  context "with custom scheme" do
    it "renders scheme styling" do
      render_inline(described_class.new(scheme: :red))
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
    before(:context) do
      render_inline(described_class.new) { "content" }
    end

    it "renders text styling" do
      expect(rendered_content).to have_selector("span.aspect-auto.items-center.justify-center.text-white")
    end
  end

  context "with legend slot" do
    before(:context) do
      render_inline(described_class.new) do |component|
        component.legend { "legend_content" }
      end
    end

    it "wraps indicator in legend" do
      expect(rendered_content).to have_selector("span>span")
      expect(rendered_content).to have_selector("span", text: "legend_content")
    end

    it "renders legend styling" do
      expect(rendered_content).to have_selector("span.flex.items-center.text-sm.font-medium")
    end
  end
end
