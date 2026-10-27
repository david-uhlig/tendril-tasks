require "rails_helper"

RSpec.describe Gustwave::Tabs, type: :component do
  def classes_of(selector)
    page.find(selector)[:class].to_s.split
  end

  describe "interactive tabs" do
    before do
      render_inline(described_class.new(id: "x")) do |tabs|
        tabs.with_tab_button("Profile", id: "profile") { |tab| tab.with_panel { "Profile content" } }
        tabs.with_tab_button("Settings", id: "settings", selected: true) { |tab| tab.with_panel { "Settings content" } }
      end
    end

    it "renders a tablist whose triggers toggle the panels container" do
      expect(page).to have_css("ul#x-list[role=tablist][data-tabs-toggle='#x-content']")
      expect(page).to have_css("ul[role=tablist] > li[role=presentation] > button[role=tab][type=button]", count: 2)
      expect(page).to have_css("#x-content > div[role=tabpanel]", count: 2)
    end

    it "pairs each trigger with its panel" do
      expect(page).to have_css(
        "button#profile-tab[aria-controls=profile][data-tabs-target='#profile'][aria-selected=false]"
      )
      expect(page).to have_css("div#profile[role=tabpanel][aria-labelledby=profile-tab]", text: "Profile content")
    end

    it "selects the tab given selected: true and shows only its panel" do
      expect(page).to have_css("button#settings-tab[aria-selected=true]")
      expect(page).to have_css("div#settings:not(.hidden)", text: "Settings content")
      expect(page).to have_css("div#profile.hidden", count: 1)
      expect(page).to have_css("[role=tabpanel]:not(.hidden)", count: 1)
    end
  end

  describe "selection" do
    it "selects the first tab that isn't disabled by default" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_button("A", id: "a", disabled: true)
        tabs.with_tab_button("B", id: "b")
        tabs.with_tab_button("C", id: "c")
      end

      expect(page).to have_css("button#b-tab[aria-selected=true]")
      expect(page).to have_css("button#c-tab[aria-selected=false]")
    end

    it "skips a disabled tab given selected: true" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_button("A", id: "a", selected: true, disabled: true)
        tabs.with_tab_button("B", id: "b")
      end

      expect(page).to have_css("button#b-tab[aria-selected=true]")
      expect(page).to have_css("button#a-tab[disabled][aria-disabled=true]")
    end
  end

  describe "disabled button tabs" do
    before do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_button("Soon", id: "soon", disabled: true) { |tab| tab.with_panel { "never" } }
        tabs.with_tab_button("Now", id: "now")
      end
    end

    it "renders a disabled button that isn't a tab" do
      expect(page).to have_css("button#soon-tab[disabled][aria-disabled=true]:not([role])")
      expect(classes_of("button#soon-tab")).to include("text-gray-400", "cursor-not-allowed")
    end

    it "renders no panel for a disabled tab" do
      expect(page).to have_css("[role=tabpanel]", count: 1)
      expect(page).not_to have_css("#soon")
    end
  end

  describe "link tabs" do
    before do
      render_inline(described_class.new(style: :pills, aria: { label: "Account" })) do |tabs|
        tabs.with_tab_link("Profile", href: "/profile", selected: true)
        tabs.with_tab_link("Billing", href: "/billing")
        tabs.with_tab_link("Disabled", href: "/x", disabled: true)
      end
    end

    it "renders a nav with links, marking only the selected one as the current page" do
      expect(page).to have_css("nav[aria-label=Account] a[href='/profile'][aria-current=page]")
      expect(page).to have_css("a[href='/billing']", count: 1)
      expect(page).to have_no_css("a[href='/billing'][aria-current]")
    end

    it "renders a disabled link without href" do
      expect(page).to have_css("a[aria-disabled=true]:not([href])", text: "Disabled")
      expect(classes_of("a[aria-disabled=true]")).to include("text-gray-400")
    end

    it "renders no panels or tab roles" do
      expect(page).to have_no_css("[role=tablist], [role=tab], [role=tabpanel], [data-tabs-toggle]")
    end
  end

  describe "strict mode" do
    it "raises when button and link tabs are mixed" do
      expect do
        render_inline(described_class.new) do |tabs|
          tabs.with_tab_button("A")
          tabs.with_tab_link("B", href: "/b")
        end
      end.to raise_error(ArgumentError)
    end

    it "raises when a link tab has a panel" do
      expect do
        render_inline(described_class.new) do |tabs|
          tabs.with_tab_link("A", href: "/a") { |tab| tab.with_panel { "panel" } }
        end
      end.to raise_error(ArgumentError)
    end
  end

  describe "when not strict" do
    before { Gustwave.strict = false }

    it "renders mixed tabs as interactive tabs, with the links as plain links" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_button("A", id: "a")
        tabs.with_tab_link("B", href: "/b")
      end

      expect(page).to have_css("button#a-tab[role=tab]")
      expect(page).to have_css("a[href='/b']:not([role])")
    end

    it "ignores the panel of a link tab" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_link("A", href: "/a") { |tab| tab.with_panel { "panel" } }
      end

      expect(page).to have_no_css("[role=tabpanel]")
    end
  end

  describe "tab content" do
    it "renders the leading visual inside the trigger and the panel options on the panel" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_button("Profile", id: "profile") do |tab|
          tab.with_leading_visual_icon(:user_circle)
          tab.with_panel(class: "p-6", data: { role: "main" }) { "content" }
        end
      end

      expect(page).to have_css("button#profile-tab svg")
      expect(page).to have_css("div#profile.p-6[data-role=main]", text: "content", visible: :all)
    end

    it "uses the block content as the label when no text is given" do
      render_inline(described_class.new) do |tabs|
        tabs.with_tab_button(id: "block") { "Block label" }
      end

      expect(page).to have_css("button#block-tab", text: "Block label")
    end
  end

  describe "ids" do
    it "uses the given id for the root element" do
      render_inline(described_class.new(id: "custom")) { |tabs| tabs.with_tab_button("A") }

      expect(page).to have_css("div#custom > div > ul#custom-list")
    end
  end

  describe "active and inactive classes" do
    it "replaces the style's classes of the active and inactive states, in the trigger and the data attributes" do
      render_inline(described_class.new(style: :pills, active_class: "bg-purple-600", inactive_class: "text-purple-400")) do |tabs|
        tabs.with_tab_button("A", id: "a", selected: true)
        tabs.with_tab_button("B", id: "b")
      end

      expect(classes_of("button#a-tab")).to include("bg-purple-600").and(satisfy { !it.include?("bg-blue-600") })
      expect(classes_of("button#b-tab")).to include("text-purple-400")
      expect(page.find("ul[role=tablist]")["data-tabs-active-classes"]).to include("bg-purple-600")
      expect(page.find("ul[role=tablist]")["data-tabs-active-classes"]).not_to include("bg-blue-600")
      expect(page.find("ul[role=tablist]")["data-tabs-inactive-classes"]).to include("text-purple-400")
    end
  end

  describe "the active and inactive classes of every style and vertical" do
    %i[default underline pills full_width none].product([ true, false ]).each do |style, vertical|
      it "keeps the classes of the states disjoint and renders every state class (#{style}, vertical: #{vertical})" do
        render_inline(described_class.new(style:, vertical:)) do |tabs|
          tabs.with_tab_button("A", id: "a", selected: true) { |tab| tab.with_panel { "a" } }
          tabs.with_tab_button("B", id: "b")
          tabs.with_tab_button("C", id: "c", disabled: true)
        end

        list = page.find("ul[role=tablist]")
        active = list["data-tabs-active-classes"].to_s.split
        inactive = list["data-tabs-inactive-classes"].to_s.split

        expect(active & inactive).to be_empty
        expect(active - classes_of("button#a-tab")).to be_empty
        expect(inactive - classes_of("button#b-tab")).to be_empty
      end
    end
  end

  describe "vertical" do
    it "stacks the list in a column" do
      render_inline(described_class.new(style: :underline, vertical: true)) do |tabs|
        tabs.with_tab_button("A")
      end

      expect(classes_of("ul[role=tablist]")).to include("flex-col")
    end
  end
end
