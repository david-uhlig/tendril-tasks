require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Menus::List, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(id: "dropdown-45dfg"))
    end

    it "renders div tag" do
      expect(rendered_content).to have_selector("div")
    end

    it "renders id attribute" do
      expect(rendered_content).to have_selector("div[id='dropdown-45dfg']")
    end

    it "renders list tag" do
      expect(rendered_content).to have_selector("div>ul")
    end

    it "renders list styling" do
      expect(rendered_content).to have_selector("div>ul.py-2.text-sm.text-gray-700")
    end

    it "doesn't render block content" do
      expect(rendered_content).not_to have_content("content")
    end
  end

  context "with content_for argument" do
    it "renders menu content elsewhere" do
      render_inline(described_class.new(id: "dropdown", content_for: :menu_area))
      expect(rendered_content).to be_empty
    end
  end

  context "#configure_list" do
    it "renders custom list tag" do
      render_inline(described_class.new(id: "dropdown")) do
        it.configure_list(tag: :ol)
      end
      expect(rendered_content).to have_selector("div[id='dropdown']>ol")
    end

    it "renders custom list HTML attributes" do
      render_inline(described_class.new(id: "dropdown")) do
        it.configure_list(id: "list-1234", class: "bg-white")
      end
      expect(rendered_content).to have_selector("div>ul[id='list-1234'].bg-white")
    end
  end

  describe "Slots" do
    context "with list item" do
      it "renders generic item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.generic_item { "generic_item_content" }
        end
        expect(rendered_content).to have_selector("div>ul>li", text: "generic_item_content")
      end

      it "renders link button item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.item { "item_content" }
        end
        expect(rendered_content).to have_selector("div>ul>li>a", text: "item_content")
      end

      it "renders divider item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.divider
        end
        expect(rendered_content).to have_selector("div>ul>li>div")
      end

      it "renders dropdown item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.dropdown { "dropdown_content" }
        end
        expect(rendered_content).to have_selector("div>ul>li>a[role='button']", text: "dropdown_content")
      end
    end
  end
end
