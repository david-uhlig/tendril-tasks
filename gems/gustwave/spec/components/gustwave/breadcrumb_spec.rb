require "rails_helper"

RSpec.describe Gustwave::Breadcrumb, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "nav"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/", icon: :home)
        breadcrumb.with_item("Projects", href: "/projects")
        breadcrumb.with_item("Flowbite")
      end
    end

    it "renders the items in a nav and ol structure" do
      expect(rendered_content).to have_selector("nav > ol > li", count: 3)
    end

    it "labels the navigation landmark" do
      expect(rendered_content).to have_selector("nav[aria-label='Breadcrumb']")
    end

    it "links the items with an href" do
      expect(rendered_content).to have_selector("li a[href='/']", text: "Home")
      expect(rendered_content).to have_selector("li a[href='/projects']", text: "Projects")
    end

    it "marks the last item as the current page as text" do
      expect(rendered_content).to have_selector("li[aria-current='page']", count: 1)
      expect(rendered_content).to have_selector("li[aria-current='page'] span.text-gray-500", text: "Flowbite")
    end

    it "separates every item but the first with a chevron" do
      expect(rendered_content).to have_selector("li > div > svg[aria-hidden='true']", count: 2)
      expect(rendered_content).not_to have_selector("li:first-child > div")
    end

    it "renders the icon of the first item" do
      expect(rendered_content).to have_selector("li:first-child > a > svg[aria-hidden='true']")
    end
  end

  context "with a visual" do
    it "renders a solid icon set on the item before the text" do
      render_inline(described_class.new) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/") { |item| item.with_visual_icon(:home, class: "text-blue-700") }
      end

      expect(rendered_content).to have_selector("li > a > svg.text-blue-700.w-4[fill='currentColor'][aria-hidden='true']", count: 1)
      expect(rendered_content).to have_link("Home", href: "/")
    end

    it "renders a component set as the visual" do
      render_inline(described_class.new) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/") { |item| item.with_visual_renderable(Gustwave::Icon.new(:home, class: "text-blue-700")) }
      end

      expect(rendered_content).to have_selector("li > a > svg.text-blue-700", count: 1)
    end
  end

  context "with the solid style" do
    it "gives the nav a bordered background" do
      render_inline(described_class.new(solid: true)) { |breadcrumb| breadcrumb.with_item("Home") }

      expect(rendered_content).to have_selector("nav.rounded-lg.bg-gray-50.border")
    end
  end

  context "with the slash separator" do
    it "separates the items with a slash and no chevron" do
      render_inline(described_class.new(separator: :slash)) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/")
        breadcrumb.with_item("Projects")
      end

      expect(rendered_content).to have_selector("span[aria-hidden='true']", text: "/", count: 1)
      expect(rendered_content).not_to have_selector("svg")
    end

    it "doesn't indent the content after the slash" do
      render_inline(described_class.new(separator: :slash)) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/")
        breadcrumb.with_item("Projects")
      end

      expect(rendered_content).to have_selector("span.text-sm", text: "Projects")
      expect(rendered_content).not_to have_selector("span.ms-1", text: "Projects")
    end
  end

  context "with custom list options" do
    it "adds the classes to the ol element" do
      render_inline(described_class.new(list_options: { class: "mb-3 sm:mb-0" })) do |breadcrumb|
        breadcrumb.with_item("Home")
      end

      expect(rendered_content).to have_selector("ol.mb-3.sm\\:mb-0.inline-flex")
    end
  end

  context "with aria overrides" do
    it "replaces the default label" do
      render_inline(described_class.new(aria: { label: "Path" })) { |breadcrumb| breadcrumb.with_item("Home") }

      expect(rendered_content).to have_selector("nav[aria-label='Path']")
      expect(rendered_content).not_to have_selector("nav[aria-label='Breadcrumb']")
    end
  end

  context "with block content" do
    it "renders the block after the list" do
      render_inline(described_class.new(class: "justify-between")) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/")
        "<button>Actions</button>".html_safe
      end

      expect(rendered_content).to have_selector("nav > ol + button", text: "Actions")
    end
  end

  context "with items set in a block" do
    it "renders the block of an item in place of its text" do
      render_inline(described_class.new) do |breadcrumb|
        breadcrumb.with_item { "Issue #312".html_safe + " docs".html_safe }
      end

      expect(rendered_content).to have_selector("li", text: "Issue #312 docs")
      expect(rendered_content).not_to have_selector("li > span")
    end

    it "sets the block in the item's text style" do
      render_inline(described_class.new) do |breadcrumb|
        breadcrumb.with_item("Home", href: "/")
        breadcrumb.with_item { "Issue #312" }
      end

      expect(rendered_content).to have_selector("li[aria-current='page'] div.text-sm.font-medium.text-gray-500.ms-1", text: "Issue #312")
    end

    it "gives the text precedence over the block" do
      render_inline(described_class.new) do |breadcrumb|
        breadcrumb.with_item("Text") { "Block" }
      end

      expect(rendered_content).to have_selector("li > span", text: "Text")
      expect(rendered_content).not_to have_text("Block")
    end
  end

  context "without items" do
    it "renders an empty list" do
      render_inline(described_class.new)

      expect(rendered_content).to have_selector("nav > ol")
      expect(rendered_content).not_to have_selector("li")
    end
  end
end
