require "rails_helper"

RSpec.describe Gustwave::List, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "ul"

  context "with the default tag" do
    before(:each) do
      render_inline(described_class.new) do |list|
        list.with_item "Acme"
        list.with_item "Icons"
      end
    end

    it "renders an unordered list with disc markers, gray text and spacing between the items" do
      expect(rendered_content).to have_selector("ul.list-disc.list-inside.text-gray-500.dark\\:text-gray-400.space-y-1")
    end

    it "renders the items as li elements with their text" do
      expect(rendered_content).to have_selector("ul > li", count: 2)
      expect(rendered_content).to have_selector("ul > li", text: "Acme")
      expect(rendered_content).to have_selector("ul > li", text: "Icons")
    end

    it "adds no role" do
      expect(page.find("ul")[:role]).to be_nil
    end
  end

  context "with tag: :ol" do
    it "renders an ordered list with decimal markers" do
      render_inline(described_class.new(tag: :ol)) { |list| list.with_item "Sign up" }

      expect(rendered_content).to have_selector("ol.list-decimal.list-inside > li", text: "Sign up")
      expect(rendered_content).not_to have_selector("ol.list-disc")
    end
  end

  context "with a marker" do
    it "renders decimal markers in an unordered list" do
      render_inline(described_class.new(tag: :ul, marker: :decimal)) { |list| list.with_item "Acme" }

      expect(rendered_content).to have_selector("ul.list-decimal")
      expect(rendered_content).not_to have_selector("ul.list-disc")
    end

    it "renders no marker classes and a list role with marker: :none" do
      render_inline(described_class.new(marker: :none)) { |list| list.with_item "Acme" }

      expect(rendered_content).not_to have_selector("ul[class*='list-']")
      expect(page.find("ul")[:role]).to eq("list")
    end

    it "keeps a role given by the caller with marker: :none" do
      render_inline(described_class.new(marker: :none, role: "navigation")) { |list| list.with_item "Acme" }

      expect(page.find("ul")[:role]).to eq("navigation")
    end
  end

  context "with color: :none" do
    it "adds no gray classes" do
      render_inline(described_class.new(color: :none)) { |list| list.with_item "Acme" }

      expect(rendered_content).not_to have_selector("ul.text-gray-500")
      expect(page.find("ul")[:class].split).not_to include("text-gray-500", "dark:text-gray-400")
    end
  end

  context "with class:" do
    it "merges the classes with the defaults" do
      render_inline(described_class.new(class: "max-w-md")) { |list| list.with_item "Acme" }

      expect(rendered_content).to have_selector("ul.max-w-md.list-disc.space-y-1")
    end
  end

  context "with nested: true" do
    it "indents the list" do
      render_inline(described_class.new(nested: true)) { |list| list.with_item "Acme" }

      expect(rendered_content).to have_selector("ul.ps-5.mt-2")
    end
  end

  context "with divided: true" do
    it "separates the items with lines and no vertical spacing" do
      render_inline(described_class.new(divided: true)) { |list| list.with_item "Acme" }

      expect(rendered_content).to have_selector("ul.space-y-0.divide-y.divide-gray-200.dark\\:divide-gray-700")
      expect(page.find("ul")[:class].split).not_to include("space-y-1")
    end

    it "pads the first, middle and last items" do
      render_inline(described_class.new(divided: true)) do |list|
        list.with_item "Acme"
        list.with_item "Icons"
        list.with_item "Fonts"
      end

      expect(rendered_content).to have_selector("li.pb-3.sm\\:pb-4", text: "Acme")
      expect(rendered_content).to have_selector("li.py-3.sm\\:py-4", text: "Icons")
      expect(rendered_content).to have_selector("li.pt-3.sm\\:pt-4", text: "Fonts")
      expect(rendered_content).not_to have_selector("li.pt-3.pb-3")
    end

    it "adds no padding to a single item" do
      render_inline(described_class.new(divided: true)) { |list| list.with_item "Acme" }

      expect(page.find("li")[:class].to_s.split).not_to include("pb-3", "py-3", "pt-3")
    end

    it "leaves the items of a list that isn't divided unpadded" do
      render_inline(described_class.new) do |list|
        list.with_item "Acme"
        list.with_item "Icons"
      end

      expect(rendered_content).not_to have_selector("li.py-3, li.pb-3, li.pt-3")
    end
  end

  context "with orientation: :horizontal" do
    it "lays the items out in a row without vertical spacing" do
      render_inline(described_class.new(orientation: :horizontal)) do |list|
        list.with_item "Acme"
        list.with_item "Icons"
      end

      expect(rendered_content).to have_selector("ul.flex.flex-wrap.items-center")
      expect(page.find("ul")[:class].split).not_to include("space-y-1")
      expect(rendered_content).to have_selector("li.me-4.md\\:me-6", count: 2)
    end
  end

  context "with an item icon" do
    it "renders the icon beside the text in a flex row" do
      render_inline(described_class.new) { |list| list.with_item "Acme", icon: :check }

      item = page.find("li")
      expect(item[:class].split).to include("flex", "items-center", "gap-2")
      expect(item[:class].split).not_to include("inline-flex")
      expect(item).to have_selector("svg.size-4\\.5.-m-0\\.5.shrink-0[aria-hidden='true']")
      expect(item).to have_text("Acme")
    end

    it "passes the classes of a leading visual icon to its svg" do
      render_inline(described_class.new) do |list|
        list.with_item "Acme" do |item|
          item.with_leading_visual_icon(:check_circle, theme: :solid, class: "text-green-500")
        end
      end

      expect(page.find("li")).to have_selector("svg.text-green-500.size-4\\.5[aria-hidden='true']")
    end
  end

  context "with an indented item block" do
    it "starts the item at its content, as a text item does" do
      render_inline(described_class.new) do |list|
        list.with_item { "\n    <strong>Acme</strong> Icons\n".html_safe }
      end

      expect(rendered_content).to include("<li><strong>Acme</strong> Icons\n</li>")
    end

    it "keeps escaping a block that isn't safe" do
      render_inline(described_class.new) do |list|
        list.with_item { "  <b>Acme</b>" }
      end

      expect(rendered_content).to include("<li>&lt;b&gt;Acme&lt;/b&gt;</li>")
    end
  end

  context "with an item block" do
    it "renders a nested list inside the item" do
      nested = described_class.new(tag: :ol, nested: true)
      nested.with_item "Tokens"

      render_inline(described_class.new) do |list|
        list.with_item { nested.render_in(vc_test_controller.view_context) }
      end

      expect(rendered_content).to have_selector("li > ol.list-decimal.ps-5 > li", text: "Tokens")
    end
  end
end
