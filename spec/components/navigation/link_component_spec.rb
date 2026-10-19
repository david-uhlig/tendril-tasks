# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::LinkComponent, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders content" do
      expect(page).to have_text("content")
    end

    it "renders link tag" do
      expect(page).to have_selector("a[href='#']", count: 1)
    end

    it "renders css class" do
      expect(page).to have_css("a.nav-link")
    end
  end

  context "without name and content" do
    # Default link_to helper behaviour
    it "renders href as content" do
      render_inline(described_class.new(href: "https://example.com"))
      expect(page).to have_text("https://example.com")
    end
  end

  context "with name" do
    it "renders name" do
      render_inline(described_class.new(name: "link_name"))
      expect(page).to have_text("link_name")
    end

    it "renders content when content is given" do
      render_inline(described_class.new(name: "link_name")) { "content" }
      expect(page).to have_text("content")
      expect(page).not_to have_text("link_name")
    end
  end

  context "with href" do
    it "links to href" do
      render_inline(described_class.new(href: "https://example.com")) { "content" }
      expect(page).to have_selector("a[href='https://example.com']", count: 1)
    end
  end

  context "with href to current page" do
    before(:each) do
      with_request_url("/users/sign-in") do
        render_inline(described_class.new(href: "/users/sign-in")) { "content" }
      end
    end

    it "renders active css class" do
      expect(page).to have_css("a.nav-link--active")
    end

    it "renders accessibility attributes" do
      expect(page).to have_selector("a[aria-current='page']")
    end
  end

  context "with active: true" do
    before(:each) do
      # The current page differs from href, so only `active: true` can mark the link active.
      with_request_url("/") do
        render_inline(described_class.new(href: "/users/sign-in", active: true)) { "content" }
      end
    end

    it "renders active css class" do
      expect(page).to have_css("a.nav-link--active")
    end

    it "renders accessibility attributes" do
      expect(page).to have_selector("a[aria-current='page']")
    end
  end
end
