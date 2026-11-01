require "rails_helper"

RSpec.describe Gustwave::Navbar, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "nav"

  it "renders a nav element" do
    render_inline(described_class.new)
    expect(rendered_content).to have_selector("nav.bg-white")
  end

  context "with menu_id" do
    it "uses the given menu id" do
      render_inline(described_class.new(menu_id: "main-menu")) { |navbar| navbar.with_item_link("Home", href: "/") }
      expect(rendered_content).to have_selector("div[id='main-menu']")
    end

    it "generates a menu id starting with navbar-" do
      navbar = described_class.new
      render_inline(navbar) { |nav| nav.with_item_link("Home", href: "/") }
      expect(navbar.menu_id).to start_with("navbar-")
      expect(rendered_content).to have_selector("div[id='#{navbar.menu_id}']")
    end
  end

  context "without items" do
    before(:each) do
      render_inline(described_class.new) { |navbar| navbar.with_brand { "Brand" } }
    end

    it "renders no toggle" do
      expect(rendered_content).not_to have_selector("button[data-collapse-toggle]")
    end

    it "renders no menu" do
      expect(rendered_content).not_to have_selector("div.hidden.md\\:flex")
      expect(rendered_content).not_to have_selector("ul")
    end
  end

  context "with items" do
    before(:each) do
      render_inline(described_class.new(menu_id: "main-menu")) do |navbar|
        navbar.with_item_link("Home", href: "/")
      end
    end

    it "renders the toggle with data-collapse-toggle pointing to the menu" do
      expect(rendered_content).to have_selector("button[data-collapse-toggle='main-menu']")
    end

    it "renders the toggle with aria-controls pointing to the menu" do
      expect(rendered_content).to have_selector("button[aria-controls='main-menu'][aria-expanded='false']")
    end

    it "renders the toggle as a button" do
      expect(rendered_content).to have_selector("button[type='button']")
    end

    it "labels the toggle in English" do
      I18n.with_locale(:en) do
        render_inline(described_class.new(menu_id: "main-menu")) { |navbar| navbar.with_item_link("Home", href: "/") }
      end
      expect(rendered_content).to have_selector("button span.sr-only", text: "Open main menu", visible: :all)
    end

    it "labels the toggle in German" do
      I18n.with_locale(:de) do
        render_inline(described_class.new(menu_id: "main-menu")) { |navbar| navbar.with_item_link("Home", href: "/") }
      end
      expect(rendered_content).to have_selector("button span.sr-only", text: "Hauptmenü öffnen", visible: :all)
    end

    it "hides the icon from screen readers" do
      expect(rendered_content).to have_selector("button svg[aria-hidden='true']")
    end

    it "draws the bars icon" do
      expect(rendered_content).to have_selector("button svg.h-7.w-7[aria-hidden='true']")
    end

    it "composes the toggle's look, without the inline button's defaults" do
      expect(rendered_content).to have_selector("button.size-10.rounded-lg.text-gray-500")
      expect(rendered_content).not_to have_selector("button.text-gray-400")
      expect(rendered_content).not_to have_selector("button.rounded-xs")
    end
  end

  describe "#with_item_link" do
    it "renders a list item wrapping a link" do
      render_inline(described_class.new) { |navbar| navbar.with_item_link("Home", href: "/home") }
      expect(rendered_content).to have_selector("ul > li > a[href='/home']", text: "Home")
    end

    it "marks an active link as the current page" do
      render_inline(described_class.new) { |navbar| navbar.with_item_link("Home", href: "/", active: true) }
      expect(rendered_content).to have_selector("li > a[href='/'][aria-current='page']")
    end

    it "renders no aria-current on an inactive link" do
      render_inline(described_class.new) { |navbar| navbar.with_item_link("Home", href: "/") }
      expect(rendered_content).not_to have_selector("a[aria-current]")
    end
  end

  describe "#with_item_generic" do
    it "passes its attributes to the list item" do
      render_inline(described_class.new) do |navbar|
        navbar.with_item_generic(class: "md:hidden", id: "mobile-only") { "<span>Search</span>".html_safe }
      end
      expect(rendered_content).to have_selector("li.md\\:hidden#mobile-only > span", text: "Search")
    end
  end

  describe "#with_brand" do
    it "renders a div without href" do
      render_inline(described_class.new) { |navbar| navbar.with_brand { "Brand" } }
      expect(rendered_content).to have_selector("div.flex.items-center", text: "Brand")
      expect(rendered_content).not_to have_selector("a")
    end

    it "renders a link with href" do
      render_inline(described_class.new) { |navbar| navbar.with_brand(href: "/") { "Brand" } }
      expect(rendered_content).to have_selector("a[href='/'].flex.items-center", text: "Brand")
    end

    it "renders its block inside the link" do
      render_inline(described_class.new) { |navbar| navbar.with_brand(href: "/") { "Block brand" } }
      expect(rendered_content).to have_selector("a[href='/']", text: "Block brand")
    end

    it "composes the link from Gustwave::Link without its own styles" do
      render_inline(described_class.new) { |navbar| navbar.with_brand(href: "/") { "Brand" } }
      expect(rendered_content).to have_selector("a[href='/'].flex.items-center")
      expect(rendered_content).not_to have_selector("a.font-medium")
      expect(rendered_content).not_to have_selector("a[class*='underline']")
    end
  end

  describe "#with_actions" do
    it "hides the actions container on wide screens when it only holds the toggle" do
      render_inline(described_class.new) { |navbar| navbar.with_item_link("Home", href: "/") }
      expect(rendered_content).to have_selector("div.md\\:order-2.md\\:hidden button")
    end

    it "keeps the actions container on wide screens when it has actions" do
      render_inline(described_class.new) do |navbar|
        navbar.with_actions { "Action" }
        navbar.with_item_link("Home", href: "/")
      end
      expect(rendered_content).not_to have_selector("div.md\\:order-2.md\\:hidden")
    end

    it "renders the actions before the toggle inside the actions container" do
      render_inline(described_class.new(menu_id: "menu")) do |navbar|
        navbar.with_actions { "<button>Sign in</button>".html_safe }
        navbar.with_item_link("Home", href: "/")
      end

      expect(rendered_content).to have_selector("div.md\\:order-2 > button + button[data-collapse-toggle='menu']")
    end
  end

  context "with sticky" do
    it "adds the sticky classes to the root" do
      render_inline(described_class.new(sticky: true))
      expect(rendered_content).to have_selector("nav.fixed.w-full.z-20.top-0.start-0")
    end

    it "does not add the sticky classes by default" do
      render_inline(described_class.new)
      expect(rendered_content).not_to have_selector("nav.fixed")
    end
  end

  context "with solid" do
    it "adds the solid classes to the root" do
      render_inline(described_class.new(solid: true))
      expect(rendered_content).to have_selector("nav.bg-gray-50.dark\\:bg-gray-800")
    end

    it "adds the solid classes to the list" do
      render_inline(described_class.new(solid: true)) { |navbar| navbar.with_item_link("Home", href: "/") }
      expect(rendered_content).to have_selector("ul.p-0.border-0.md\\:bg-transparent")
    end
  end

  context "with sticky and solid" do
    it "adds the classes of both" do
      render_inline(described_class.new(sticky: true, solid: true))
      expect(rendered_content).to have_selector("nav.fixed.bg-gray-50")
    end
  end

  describe "#configure_container" do
    it "lets its classes win conflicts with the defaults" do
      render_inline(described_class.new) do |navbar|
        navbar.configure_container(class: "max-w-(--breakpoint-lg)")
        navbar.with_brand { "Brand" }
      end
      expect(rendered_content).to have_selector("div.max-w-\\(--breakpoint-lg\\)")
      expect(rendered_content).not_to have_selector("div.max-w-screen-xl")
    end
  end

  describe "#configure_menu" do
    it "lets its classes win conflicts with the defaults" do
      render_inline(described_class.new(menu_id: "menu")) do |navbar|
        navbar.configure_menu(class: "md:ms-auto md:me-8")
        navbar.with_item_link("Home", href: "/")
      end
      expect(rendered_content).to have_selector("div[id='menu'].md\\:ms-auto.md\\:me-8")
    end
  end
end
