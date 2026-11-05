require "rails_helper"

RSpec.describe Gustwave::ListGroup, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "ul"

  context "with text items" do
    before(:each) do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_text("Profile")
        list_group.with_item_text("Settings")
        list_group.with_item_text("Download")
      end
    end

    it "renders the items as li elements in a ul" do
      expect(rendered_content).to have_selector("ul > li", count: 3)
      expect(rendered_content).to have_selector("ul > li", text: "Settings")
    end

    it "rounds only the outer corners and separates the items with a border" do
      expect(rendered_content).to have_selector("li.rounded-t-lg.border-b", text: "Profile")
      expect(rendered_content).to have_selector("li.border-b", text: "Settings")
      expect(rendered_content).to have_selector("li.rounded-b-lg", text: "Download")
      expect(rendered_content).not_to have_selector("li.rounded-b-lg.border-b")
    end

    it "styles the list" do
      expect(rendered_content).to have_selector("ul.rounded-lg.border.text-sm.font-medium")
    end
  end

  context "with a single text item" do
    it "rounds all corners of the item" do
      render_inline(described_class.new) { |list_group| list_group.with_item_text("Profile") }

      expect(rendered_content).to have_selector("li.rounded-lg", text: "Profile")
      expect(rendered_content).not_to have_selector("li.border-b")
    end
  end

  context "with text from the block" do
    it "renders the block as the item content" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_text { "Messages" }
      end

      expect(rendered_content).to have_selector("li", text: "Messages")
    end

    it "prefers the text argument over the block" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_text("Messages") { "Block" }
      end

      expect(rendered_content).to have_selector("li", text: "Messages")
      expect(rendered_content).not_to have_text("Block")
    end
  end

  context "with link items" do
    before(:each) do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_link("Profile", href: "/profile", active: true)
        list_group.with_item_link("Settings", href: "/settings")
      end
    end

    it "renders the links as block a elements in a div" do
      expect(rendered_content).to have_selector("div > a.block[href='/profile']", text: "Profile")
      expect(rendered_content).to have_selector("div > a.block[href='/settings']", text: "Settings")
      expect(rendered_content).not_to have_selector("ul")
    end

    it "marks the active link as the current item" do
      expect(rendered_content).to have_selector("a[aria-current='true']", text: "Profile")
      expect(rendered_content).to have_selector("a.text-white.bg-blue-700", text: "Profile")
      expect(rendered_content).not_to have_selector("a.hover\\:bg-gray-100", text: "Profile")
    end

    it "shows the hover and focus states on the inactive link" do
      expect(rendered_content).to have_selector("a.hover\\:bg-gray-100.focus\\:ring-2", text: "Settings")
      expect(rendered_content).not_to have_selector("a[aria-current]", text: "Settings")
    end
  end

  context "with button items" do
    before(:each) do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_button("Profile", active: true)
        list_group.with_item_button("Messages")
        list_group.with_item_button("Download", disabled: true)
      end
    end

    it "renders the buttons with type button" do
      expect(rendered_content).to have_selector("div > button[type='button']", count: 3)
    end

    it "marks the active button as the current item" do
      expect(rendered_content).to have_selector("button[aria-current='true']", text: "Profile")
    end

    it "disables a disabled button without hover and focus states" do
      expect(rendered_content).to have_selector("button[disabled]", text: "Download")
      expect(rendered_content).to have_selector("button.cursor-not-allowed.bg-gray-100", text: "Download")
      expect(rendered_content).not_to have_selector("button.hover\\:bg-gray-100", text: "Download")
    end

    it "keeps the hover and focus states on an enabled button" do
      expect(rendered_content).to have_selector("button.hover\\:bg-gray-100", text: "Messages")
      expect(rendered_content).not_to have_selector("button[disabled]", text: "Messages")
    end
  end

  context "with a text item among link items" do
    it "renders the text item as a div, so the markup stays valid" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_text("Heading")
        list_group.with_item_link("Profile", href: "/profile")
      end

      expect(rendered_content).to have_selector("div > div", text: "Heading")
      expect(rendered_content).not_to have_selector("li")
    end
  end

  context "with icons" do
    it "renders a decorative icon before the text of a button" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_button("Profile", icon: :user_circle)
      end

      expect(rendered_content).to have_selector("button.relative.inline-flex svg.w-4.h-4.me-2[aria-hidden='true']")
      expect(rendered_content).to have_selector("button", text: "Profile")
    end

    it "renders solid icons by default and outline icons on request" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_button("Profile", icon: :user_circle)
        list_group.with_item_button("Messages") { |item| item.with_icon(:envelope, theme: :outline) }
      end

      expect(rendered_content).to have_selector("button:first-child svg[fill='currentColor']")
      expect(rendered_content).to have_selector("button:last-child svg[fill='none']")
    end

    it "sets the icon through its slot" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_link("Messages", href: "/messages") do |item|
          item.with_icon(:envelope)
        end
      end

      expect(rendered_content).to have_selector("a.relative svg", count: 1)
    end
  end

  context "with a renderable item" do
    it "renders the component as is" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_renderable(Gustwave::ListGroup::Item.new("Profile", tag: :a, href: "/profile"))
      end

      expect(rendered_content).to have_selector("a[href='/profile']", text: "Profile")
    end
  end

  context "with a block" do
    it "renders the block after the items" do
      render_inline(described_class.new) do |list_group|
        list_group.with_item_text("Profile")
        "<li>Extra</li>".html_safe
      end

      expect(rendered_content).to have_selector("ul > li", count: 2)
    end
  end
end
