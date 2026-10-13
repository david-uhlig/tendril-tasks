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
  end
end
