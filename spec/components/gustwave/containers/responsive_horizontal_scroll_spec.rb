require "rails_helper"

RSpec.describe Gustwave::Containers::ResponsiveHorizontalScroll, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:context) do
      render_inline(described_class.new) { "content" }
    end

    it "renders div tag" do
      expect(rendered_content).to have_selector("div")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("div.flex.flex-nowrap.overflow-x-auto.touch-pan-x")
    end

    it "renders breakpoint attribute styling" do
      expect(rendered_content).to have_selector('div.md\:flex-wrap.md\:overflow-visible')
    end

    it "renders content" do
      expect(rendered_content).to have_selector("div", text: "content")
    end
  end

  context "with snap argument" do
    it "renders snap attribute styling" do
      render_inline(described_class.new(snap: "center"))
      expect(rendered_content).to have_selector('div.snap-center.snap-x')
    end
  end

  context "with breakpoint argument" do
    it "renders breakpoint attribute styling" do
      render_inline(described_class.new(breakpoint: "lg"))
      expect(rendered_content).to have_selector('div.lg\:flex-wrap.lg\:overflow-visible')
    end
  end

  context "with tag argument" do
    it "renders the tag" do
      render_inline(described_class.new(tag: :span))
      expect(rendered_content).to have_selector("span")
    end
  end

  context "with item slot" do
    context "automatically resolves the item tag" do
      it "renders a div tag when the component is rendered with default values" do
        render_inline(described_class.new) do
          it.item { "item_content" }
        end
        expect(rendered_content).to have_selector("div>div", text: "item_content")
      end

      it "renders a span tag when the component is rendered in a span tag" do
        render_inline(described_class.new(tag: :span)) do
          it.item { "item_content" }
        end
        expect(rendered_content).to have_selector("span>span", text: "item_content")
      end

      it "renders a li tag when the component is rendered in a ul tag" do
        render_inline(described_class.new(tag: :ul)) do
          it.item { "item_content" }
        end
        expect(rendered_content).to have_selector("ul>li", text: "item_content")
      end

      it "renders a li tag when the component is rendered in a ol tag" do
        render_inline(described_class.new(tag: :ol)) do
          it.item { "item_content" }
        end
        expect(rendered_content).to have_selector("ol>li", text: "item_content")
      end
    end

    context "with item tag argument" do
      it "renders the item tag" do
        render_inline(described_class.new(tag: :span)) do
          it.item(tag: :div) { "item_content" }
        end
        expect(rendered_content).to have_selector("span>div", text: "item_content")
      end
    end

    context "with text argument" do
      it "renders the text" do
        render_inline(described_class.new) do
          it.item("item_content")
        end
        expect(rendered_content).to have_content("item_content")
      end

      it "renders text over block content" do
        render_inline(described_class.new) do
          it.item("item_content") { "block_content" }
        end
        expect(rendered_content).to have_content("item_content")
        expect(rendered_content).not_to have_content("block_content")
      end

      it "renders html attributes" do
        render_inline(described_class.new) do
          it.item("item_content", class: "item-class", id: "item-1234")
        end
        expect(rendered_content).to have_selector("div>div#item-1234.item-class", text: "item_content")
      end
    end
  end
end
