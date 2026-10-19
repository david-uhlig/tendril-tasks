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
  end

  context "with trigger settings" do
    it "renders the trigger_event as data attribute" do
      render_inline(described_class.new("Menu", trigger_event: :hover))

      expect(rendered_content).to have_selector("button[data-dropdown-trigger='hover']")
    end

    it "renders the delay as data attribute" do
      render_inline(described_class.new("Menu", delay: 500))

      expect(rendered_content).to have_selector("button[data-dropdown-delay='500']")
    end

    it "renders the placement as data attribute" do
      render_inline(described_class.new("Menu", placement: :top))

      expect(rendered_content).to have_selector("button[data-dropdown-placement='top']")
    end

    it "renders the offset_distance as data attribute" do
      render_inline(described_class.new("Menu", offset_distance: 10))

      expect(rendered_content).to have_selector("button[data-dropdown-offset-distance='10']")
    end

    it "renders the offset_skidding as data attribute" do
      render_inline(described_class.new("Menu", offset_skidding: 5))

      expect(rendered_content).to have_selector("button[data-dropdown-offset-skidding='5']")
    end

    it "passes the placement to a generic trigger" do
      render_inline(described_class.new(placement: :top)) do |dropdown|
        dropdown.with_trigger_generic { "Trigger" }
      end

      expect(rendered_content).to have_selector("[data-dropdown-placement='top']", text: "Trigger")
    end
  end

  context "with a custom trigger component" do
    it "renders the given component as the trigger wired to the menu" do
      render_inline(described_class.new(menu_id: "m", trigger_event: :hover)) do |dropdown|
        dropdown.with_trigger_component("Open", component: Gustwave::Dropdowns::Triggers::InlineButton)
      end

      expect(rendered_content).to have_selector(
        "button.align-baseline[data-dropdown-toggle='m'][aria-controls='m'][data-dropdown-trigger='hover']",
        text: "Open"
      )
      expect(rendered_content).to have_no_selector("button.bg-blue-700")
    end

    it "renders a Button trigger when no component is given" do
      render_inline(described_class.new(menu_id: "m")) do |dropdown|
        dropdown.with_trigger_component("Open")
      end

      expect(rendered_content).to have_selector("button[data-dropdown-toggle='m'].bg-blue-700", text: "Open")
      expect(rendered_content).to have_no_selector("button.align-baseline")
    end
  end

  context "with inline" do
    it "renders an inline trigger" do
      render_inline(described_class.new("Menu", menu_id: "m", inline: true))

      expect(rendered_content).to have_selector("button.align-baseline[data-dropdown-toggle='m']", text: "Menu")
    end
  end

  context "with a generic menu" do
    it "renders the menu content with the menu id" do
      render_inline(described_class.new("Open", menu_id: "m")) do |dropdown|
        dropdown.with_menu_generic("Menu body")
      end

      expect(rendered_content).to have_selector("div#m", text: "Menu body")
    end

    it "renders the menu in the given tag" do
      render_inline(described_class.new("Open", menu_id: "m")) do |dropdown|
        dropdown.with_menu_generic("Menu body", tag: :section)
      end

      expect(rendered_content).to have_selector("section#m", text: "Menu body")
    end
  end

  context "with list options" do
    it "configures the list element" do
      render_inline(described_class.new("Open", menu_id: "m")) do |dropdown|
        dropdown.with_menu_list(list_options: { tag: :ol }) do |menu|
          menu.with_item_link "Profile", href: "/profile"
        end
      end

      expect(rendered_content).to have_selector("#m ol a[href='/profile']", text: "Profile")
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
