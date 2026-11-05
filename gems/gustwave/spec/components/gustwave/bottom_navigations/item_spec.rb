require "rails_helper"

RSpec.describe Gustwave::BottomNavigations::Item, type: :component do
  it_behaves_like "a component with configurable html attributes", "Home", selector: "button"

  context "with the tag" do
    it "renders a button of type button by default" do
      render_inline(described_class.new("Home"))

      expect(page).to have_selector("button[type='button']", text: "Home")
    end

    it "renders a link with its href and no type" do
      render_inline(described_class.new("Home", tag: :a, href: "/home"))

      expect(page).to have_selector("a[href='/home']", text: "Home")
      expect(page).not_to have_selector("a[type]")
    end
  end

  context "with the label" do
    it "renders the label under the icon" do
      render_inline(described_class.new("Home", icon: :home))

      expect(page).to have_selector("button svg + span.text-sm", text: "Home")
    end

    it "renders the label as sr-only text with a tooltip when label_display is :tooltip" do
      render_inline(described_class.new("Home", icon: :home, label_display: :tooltip))

      expect(page).to have_selector("button span.sr-only", text: "Home")
      expect(page).to have_selector("button + [role=tooltip]", text: "Home", visible: :all)
    end

    it "points the button at the tooltip, without aria-describedby" do
      render_inline(described_class.new("Home", label_display: :tooltip))

      tooltip_id = page.find("[role=tooltip]", visible: :all)[:id]
      expect(page.find("button")["data-tooltip-target"]).to eq(tooltip_id)
      expect(page.find("button")["aria-describedby"]).to be_nil
    end

    it "takes the label from block content when no text is given" do
      render_inline(described_class.new) { "Profile" }

      expect(page).to have_selector("button span.text-sm", text: "Profile")
    end
  end

  context "with the icon" do
    it "renders the icon from the icon keyword, hidden from screen readers" do
      render_inline(described_class.new("Home", icon: :home))

      expect(page).to have_selector("button svg[aria-hidden='true']")
    end

    it "renders the icon set through the icon slot, with its theme" do
      render_inline(described_class.new("Wallet")) do |item|
        item.with_icon(:wallet, theme: :outline, class: "text-red-600")
      end

      expect(page).to have_selector("button svg.text-red-600")
    end

    it "lets the icon slot win over the icon keyword" do
      render_inline(described_class.new("Home", icon: :home)) do |item|
        item.with_icon(:wallet)
      end

      expect(page).to have_selector("button svg")
    end
  end

  context "when active" do
    it "marks a button with aria-current true and colors its icon and label" do
      render_inline(described_class.new("Home", icon: :home, active: true))

      expect(page).to have_selector("button[aria-current='true']")
      expect(page).to have_selector("button svg.text-blue-600")
      expect(page).to have_selector("button span.text-blue-600")
    end

    it "marks a link with aria-current page" do
      render_inline(described_class.new("Home", tag: :a, href: "/home", active: true))

      expect(page).to have_selector("a[aria-current='page']")
    end

    it "renders no current page marker when inactive" do
      render_inline(described_class.new("Home", icon: :home))

      expect(page).not_to have_selector("[aria-current]")
    end
  end

  context "with the slot context from its bottom navigation" do
    it "takes the classes the parent gives it on its root" do
      item = described_class.new("Home")
      item.apply_slot_context(classes: "rounded-s-full border-s", slot: :items)
      render_inline(item)

      expect(page).to have_selector("button.rounded-s-full.border-s")
    end

    it "lets the caller's class win conflicts with the parent's classes" do
      item = described_class.new("Home", class: "rounded-none")
      item.apply_slot_context(classes: "rounded-s-full")
      render_inline(item)

      expect(page).to have_selector("button.rounded-none")
      expect(page).not_to have_selector("button.rounded-s-full")
    end
  end
end
