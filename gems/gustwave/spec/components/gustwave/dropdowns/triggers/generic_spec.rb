require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Triggers::Generic, type: :component do
  with_options selector: "div", menu_id: "dropdown-menu" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu")) { "content" }
    end

    it "renders div tag" do
      expect(rendered_content).to have_selector("div")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("div.inline-flex.cursor-pointer")
    end

    it "renders the menu id as data attribute" do
      expect(rendered_content).to have_selector("div[data-dropdown-toggle='dropdown-menu']")
    end
  end

  context "with tag parameter" do
    it "renders the tag" do
      render_inline(described_class.new(tag: :span, menu_id: "dropdown-menu"))
      expect(rendered_content).to have_selector("span")
    end
  end
end
