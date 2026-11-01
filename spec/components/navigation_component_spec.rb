# frozen_string_literal: true

require "rails_helper"

RSpec.describe NavigationComponent, type: :component do
  include Devise::Test::ControllerHelpers

  context "with default values" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders no content" do
      expect(page).not_to have_content("content")
    end

    it "renders a nav element" do
      expect(page).to have_selector("nav")
    end

    it "renders no menu toggle without a menu to toggle" do
      expect(page).to have_no_selector("button[aria-controls]")
    end
  end

  context "with links" do
    it "renders a menu toggle that controls the menu holding the links" do
      render_inline(described_class.new) do |component|
        component.with_link(name: "test_link", href: "https://example.com")
      end
      toggle = page.find("button[data-collapse-toggle][aria-expanded='false']")
      expect(toggle["aria-controls"]).to be_present
      expect(page).to have_selector("##{toggle['aria-controls']} a[href='https://example.com']", text: "test_link")
    end

    it "renders the container and menu next to the actions" do
      render_inline(described_class.new) do |component|
        component.with_link(name: "test_link", href: "https://example.com")
      end
      expect(page).to have_selector("div.max-w-\\(--breakpoint-lg\\)")
      expect(page).to have_no_selector("div.max-w-screen-xl")
      expect(page).to have_selector("div.md\\:ms-auto.md\\:me-8")
    end

    it "renders the mobile sign-in or sign-out item only in the menu" do
      render_inline(described_class.new) do |component|
        component.with_link(name: "test_link", href: "https://example.com")
      end
      toggle = page.find("button[data-collapse-toggle]")
      expect(page).to have_selector("##{toggle['aria-controls']} li.md\\:hidden button.nav-link")
    end

    it "renders one link" do
      render_inline(described_class.new) do |component|
        component.with_link(name: "test_link", href: "https://example.com")
      end
      expect(page).to have_selector("a[href='https://example.com']", text: "test_link")
    end

    it "renders many links" do
      render_inline(described_class.new) do |component|
        component.with_links([
          { name: "test_link1", href: "https://example.com/1" },
          { name: "test_link2", href: "https://example.com/2" }
                             ])
      end
      expect(page).to have_selector("a[href='https://example.com/1']", text: "test_link1")
      expect(page).to have_selector("a[href='https://example.com/2']", text: "test_link2")
    end
  end
end
