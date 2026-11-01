# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Navbars::Link, type: :component do
  it_behaves_like "a text and block content renderer", selector: "a", href: "#"
  it_behaves_like "a component with configurable html attributes", selector: "a", href: "#"

  context "when inactive" do
    before(:each) do
      render_inline(described_class.new("Home", href: "/"))
    end

    it "renders the link with its href" do
      expect(page).to have_selector("a[href='/']", text: "Home")
    end

    it "renders the inactive classes" do
      expect(page).to have_selector("a.text-gray-900.hover\\:bg-gray-100")
    end

    it "renders no aria-current attribute" do
      expect(page).not_to have_selector("a[aria-current]")
    end
  end

  context "when active" do
    before(:each) do
      render_inline(described_class.new("Home", href: "/", active: true))
    end

    it "renders the active classes" do
      expect(page).to have_selector("a.text-white.bg-blue-700.md\\:text-blue-700")
    end

    it "renders no inactive classes" do
      expect(page).not_to have_selector("a.hover\\:bg-gray-100")
    end

    it "renders aria-current set to page" do
      expect(page).to have_selector("a[aria-current='page']")
    end
  end
end
