require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Menus::List, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(id: "dropdown-45dfg"))
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
  end

  context "with block content" do
    it "renders the block content after the list and before the footer" do
      render_inline(described_class.new(id: "dropdown")) do |list|
        list.with_footer("footer_content")
        list.with_item_generic { "item_content" }
        "<p>block_content</p>".html_safe
      end

      expect(rendered_content).to have_selector("div[id='dropdown'] > ul + p + footer")
      expect(rendered_content).to have_selector("div[id='dropdown'] > ul + p", text: "block_content")
    end

    it "renders no extra markup when the block only sets slots" do
      render_inline(described_class.new(id: "dropdown")) do |list|
        list.with_header("header_content")
        list.with_item_link("Profile", href: "/profile")
        list.with_footer("footer_content")
        "\n  "
      end

      menu = Capybara.string(rendered_content).find("div[id='dropdown']")
      expect(menu.native.children.map(&:name)).to eq(%w[header ul footer])
    end
  end

  context "with content_for argument" do
    it "renders menu content elsewhere" do
      render_inline(described_class.new(id: "dropdown", content_for: :menu_area))
      expect(rendered_content).to be_empty
    end
  end

  context "with header and footer" do
    it "renders the header before the list and the footer after it" do
      render_inline(described_class.new(id: "dropdown")) do |list|
        list.with_header("header_content")
        list.with_footer("footer_content")
        list.with_item_generic { "item_content" }
      end

      expect(rendered_content).to have_selector("div[id='dropdown'] > header + ul + footer")
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

    it "raises for a list tag other than ul or ol" do
      expect { described_class.new(id: "dropdown").configure_list(tag: :div) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :div for :list_tag/)
    end
  end

  describe "Slots" do
    context "with list item" do
      it "renders generic item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_item_generic { "generic_item_content" }
        end
        expect(rendered_content).to have_selector("div>ul>li", text: "generic_item_content")
      end

      it "renders link button item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_item_link { "item_content" }
        end
        expect(rendered_content).to have_selector("div>ul>li>a", text: "item_content")
      end

      it "renders divider item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_item_divider
        end
        expect(rendered_content).to have_selector("div>ul>li>div")
      end

      it "renders dropdown item" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_item_dropdown { "dropdown_content" }
        end
        expect(rendered_content).to have_selector("div>ul>li>a[role='button']", text: "dropdown_content")
      end

      it "renders the items in the order they were added" do
        render_inline(described_class.new(id: "dropdown")) do |list|
          list.with_item_link { "first_link" }
          list.with_item_divider
          list.with_item_generic { "third_item" }
        end

        expect(rendered_content).to have_selector("div>ul>li:nth-child(1)>a", text: "first_link")
        expect(rendered_content).to have_selector("div>ul>li:nth-child(2)>div")
        expect(rendered_content).to have_selector("div>ul>li:nth-child(3)", text: "third_item")
        expect(rendered_content).to have_selector("div>ul>li", count: 3)
      end
    end
  end
end
