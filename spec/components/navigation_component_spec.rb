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
  end

  context "with links" do
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

  context "with login button" do
    it "renders the login button" do
      render_inline(described_class.new) do |component|
        component.with_login_button do
          "login_with_this_button"
        end
      end
      expect(page).to have_button("login_with_this_button")
    end

    it "doesn't render the login button if user is signed in"
  end
end
