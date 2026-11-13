require "rails_helper"

RSpec.describe Gustwave::BottomNavigation, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  def items_grid = page.find("div.grid")

  context "with the placement" do
    it "fixes the bar to the bottom of the viewport by default" do
      render_inline(described_class.new) { |nav| nav.with_item_button("Home") }

      expect(page).to have_selector("div.fixed.bottom-0.left-0.border-t.h-16")
    end

    it "sticks the bar to the bottom of its container with position: :sticky" do
      render_inline(described_class.new(position: :sticky)) { |nav| nav.with_item_button("Home") }

      expect(page).to have_selector("div.sticky.bottom-0.left-0.border-t")
      expect(page).not_to have_selector("div.fixed")
    end

    it "renders the bar in the flow of the page with position: :none" do
      render_inline(described_class.new(position: :none)) { |nav| nav.with_item_button("Home") }

      expect(page).to have_selector("div.border-t")
      expect(page).not_to have_selector("div.fixed, div.sticky")
    end

    it "renders a navigation landmark with tag: :nav" do
      render_inline(described_class.new(tag: :nav, aria: { label: "Main" })) { |nav| nav.with_item_button("Home") }

      expect(page).to have_selector("nav[aria-label='Main'].fixed")
    end
  end

  context "when floating" do
    it "rounds the bar and lifts it above the bottom edge" do
      render_inline(described_class.new(floating: true)) { |nav| nav.with_item_button("Home") }

      expect(page).to have_selector("div.rounded-full.bottom-4.left-1\\/2.border")
      expect(page).not_to have_selector("div.bottom-0")
      expect(page).not_to have_selector("div.border-t")
    end

    it "rounds the outer ends of the first and last items" do
      render_inline(described_class.new(floating: true)) do |nav|
        nav.with_item_button("Home")
        nav.with_item_button("Wallet")
        nav.with_item_button("Profile")
      end

      expect(page).to have_selector("button:first-child.rounded-s-full")
      expect(page).to have_selector("button:last-child.rounded-e-full")
      expect(page).to have_selector("button:not(:first-child):not(:last-child)", count: 1)
      expect(page).not_to have_selector("button.rounded-s-full:not(:first-child)")
    end
  end

  context "with bordered items" do
    it "draws a line after each item and before the first one" do
      render_inline(described_class.new(bordered: true)) do |nav|
        nav.with_item_button("Home")
        nav.with_item_button("Wallet")
      end

      expect(page).to have_selector("button:first-child.border-s.border-e")
      expect(page).to have_selector("button:last-child.border-e")
      expect(page).not_to have_selector("button:last-child.border-s")
    end

    it "leaves the items unbordered by default" do
      render_inline(described_class.new) { |nav| nav.with_item_button("Home") }

      expect(page).not_to have_selector("button.border-e")
    end
  end

  context "with the items" do
    it "lays the items out in as many columns as there are" do
      render_inline(described_class.new) do |nav|
        nav.with_item_button("Home")
        nav.with_item_button("Wallet")
        nav.with_item_link("Profile", href: "/profile")
      end

      expect(items_grid[:class]).to include("grid-cols-3")
      expect(page).to have_selector("button", count: 2)
      expect(page).to have_selector("a[href='/profile']")
    end

    it "lets grid_options: override the number of columns" do
      render_inline(described_class.new(grid_options: { class: "grid-cols-6" })) do |nav|
        nav.with_item_button("Home")
        nav.with_item_button("Wallet")
      end

      expect(items_grid[:class]).to include("grid-cols-6")
      expect(items_grid[:class]).not_to include("grid-cols-2")
    end

    it "renders a generic item as markup, with its class, and leaves it unstyled as an item" do
      render_inline(described_class.new) do |nav|
        nav.with_item_button("Home")
        nav.with_item_generic(class: "col-span-2") { "1 of 345" }
      end

      expect(page).to have_selector("div.col-span-2.flex", text: "1 of 345")
      expect(page).not_to have_selector("div.col-span-2.rounded-s-full")
    end

    it "sets the items' edge classes on a generic item's neighbours only for button and link items" do
      render_inline(described_class.new(floating: true)) do |nav|
        nav.with_item_generic { "CTA" }
        nav.with_item_button("Profile")
      end

      expect(page).to have_selector("button.rounded-e-full")
      expect(page).not_to have_selector("button.rounded-s-full")
    end

    it "renders no grid without items" do
      render_inline(described_class.new) { "Controls" }

      expect(page).to have_no_selector("div.grid")
    end
  end

  context "with block content" do
    it "renders the content above the item grid" do
      render_inline(described_class.new) do |nav|
        nav.with_item_button("Home")
        "<div class='segments'>Segments</div>".html_safe
      end

      expect(page.find("div.segments + div.grid")).to have_selector("button", text: "Home")
    end

    it "renders only the content, filling the bar, without items" do
      render_inline(described_class.new(class: "grid grid-cols-1 px-8")) do
        "<span class='controls'>Controls</span>".html_safe
      end

      expect(page).to have_selector("div.controls, span.controls")
      expect(page).to have_selector("div.h-16.grid-cols-1.px-8")
    end

    it "stacks the items with padding and drops the fixed height when there's content" do
      render_inline(described_class.new) do |nav|
        nav.with_item_button("Home")
        "<div class='segments'>Segments</div>".html_safe
      end

      expect(page).not_to have_selector("div.h-16")
      expect(page).to have_selector("button.p-4")
    end

    it "treats whitespace as no content" do
      render_inline(described_class.new) do |nav|
        nav.with_item_button("Home")
        "\n  "
      end

      expect(page).to have_selector("div.h-16")
      expect(page).not_to have_selector("button.p-4")
    end
  end

  context "with the label display" do
    it "shows the labels under the icons by default" do
      render_inline(described_class.new) { |nav| nav.with_item_button("Home", icon: :home) }

      expect(page).to have_selector("button span.text-sm", text: "Home")
      expect(page).not_to have_selector("[role=tooltip]", visible: :all)
    end

    it "shows the labels as tooltips with label_display: :tooltip" do
      render_inline(described_class.new(label_display: :tooltip)) { |nav| nav.with_item_button("Home", icon: :home) }

      expect(page).to have_selector("button span.sr-only", text: "Home")
      expect(page).to have_selector("[role=tooltip]", text: "Home", visible: :all)
      expect(page.find("button")["data-tooltip-target"]).to eq(page.find("[role=tooltip]", visible: :all)[:id])
    end

    it "lets an item set its own label_display" do
      render_inline(described_class.new(label_display: :tooltip)) do |nav|
        nav.with_item_button("Home", label_display: :inside)
      end

      expect(page).to have_selector("button span.text-sm", text: "Home")
      expect(page).not_to have_selector("[role=tooltip]", visible: :all)
    end
  end

  context "with the icon" do
    it "renders the icon named by the item's icon keyword" do
      render_inline(described_class.new) { |nav| nav.with_item_button("Home", icon: :home) }

      expect(page).to have_selector("button svg[aria-hidden='true']")
    end
  end

  it "rejects an unknown position" do
    expect { render_inline(described_class.new(position: :top)) { |nav| nav.with_item_button("Home") } }
      .to raise_error(Gustwave::Options::UnknownValueError)
  end
end
