require "rails_helper"

RSpec.describe Gustwave::Dropdown, type: :component do
  with_options selector: "button" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      @component = described_class.new
      render_inline(@component) { "content" }
    end

    it "renders a button tag" do
      expect(rendered_content).to have_selector("button")
    end

    it "generates a random menu_id" do
      expect(@component.menu_id).to match(/dropdown-\w{5}/)
    end

    it "renders the menu_id as data attribute" do
      expect(rendered_content).to have_selector("button[data-dropdown-toggle='#{@component.menu_id}']")
    end
  end

  context "with menu_id argument" do
    before(:context) do
      @component = described_class.new(menu_id: "custom-menu-id")
      render_inline(@component)
    end

    it "exposes the menu_id" do
      expect(@component.menu_id).to eq("custom-menu-id")
    end

    it "renders the menu_id as data attribute" do
      expect(rendered_content).to have_selector("button[data-dropdown-toggle='custom-menu-id']")
    end

    it "points aria-controls at the menu" do
      expect(rendered_content).to have_selector("button[aria-controls='custom-menu-id']")
    end
  end

  context "with data attributes" do
    it "keeps the menu id next to the caller's data" do
      render_inline(described_class.new("Menu", menu_id: "m", data: { controller: "x" }))

      expect(rendered_content).to have_selector("button[data-controller='x'][data-dropdown-toggle='m']")
    end

    it "does not let the caller's data override the menu id" do
      render_inline(described_class.new("Menu", menu_id: "m", data: { "dropdown-toggle": "other" }))

      expect(rendered_content).to have_selector("button[data-dropdown-toggle='m']")
      expect(rendered_content).not_to have_selector("button[data-dropdown-toggle='other']")
    end

    it "renders aria-controls with the menu id" do
      render_inline(described_class.new("Menu", menu_id: "m"))

      expect(rendered_content).to have_selector("button[aria-controls='m']")
    end
  end

  context "with a configurable list menu class" do
    let!(:badge_list) do
      stub_const("DropdownSpecBadgeList", Class.new(Gustwave::Dropdowns::Menus::List) {
        extend_slot :items, types: { badge: ->(text) { tag.mark(text) } }
      })
    end

    def render_menu(component)
      render_inline(component) do |dropdown|
        dropdown.with_menu_list do |menu|
          menu.with_item_link "Profile", href: "/profile"
          menu.with_item_badge("New") if menu.respond_to?(:with_item_badge)
        end
      end
    end

    it "defaults to Gustwave::Dropdowns::Menus::List" do
      expect(described_class.list_menu_class).to eq("Gustwave::Dropdowns::Menus::List")

      render_menu(described_class.new(menu_id: "m"))

      expect(rendered_content).to have_selector("#m a[href='/profile']", text: "Profile")
      expect(rendered_content).not_to have_selector("mark")
    end

    it "renders the list class of a subclass without affecting Dropdown" do
      subclass = stub_const("DropdownSpecBadgeDropdown", Class.new(described_class) {
        self.list_menu_class = "DropdownSpecBadgeList"
      })

      render_menu(subclass.new(menu_id: "m"))

      expect(rendered_content).to have_selector("#m a[href='/profile']", text: "Profile")
      expect(rendered_content).to have_selector("#m mark", text: "New")
      expect(described_class.list_menu_class).to eq("Gustwave::Dropdowns::Menus::List")
    end

    it "accepts a class instead of a class name" do
      subclass = stub_const("DropdownSpecClassDropdown", Class.new(described_class) {
        self.list_menu_class = DropdownSpecBadgeList
      })

      render_menu(subclass.new(menu_id: "m"))

      expect(rendered_content).to have_selector("#m mark", text: "New")
    end

    it "renders the list class configured on Dropdown for every dropdown" do
      original = described_class.list_menu_class
      described_class.list_menu_class = "DropdownSpecBadgeList"

      render_menu(described_class.new(menu_id: "m"))

      expect(rendered_content).to have_selector("#m mark", text: "New")
    ensure
      described_class.list_menu_class = original
    end
  end
end
