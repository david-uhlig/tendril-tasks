require "rails_helper"

RSpec.describe Gustwave::Dropdowns::MenuItems::Dropdown, type: :component do
  with_options selector: "a[role='button']" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new)
    end

    it "renders anchor tag" do
      expect(rendered_content).to have_selector("a[role='button']")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("a.flex.items-center.w-full")
    end

    it "doesn't render href" do
      expect(rendered_content).not_to have_selector("a[href]")
    end

    it "renders dropdown data attributes" do
      expect(rendered_content).to have_selector("a[data-dropdown-toggle][data-dropdown-placement='right']")
    end
  end

  context "with href argument" do
    it "renders href" do
      render_inline(described_class.new(href: "/path"))
      expect(rendered_content).to have_selector("a[href='/path']")
    end
  end
end
