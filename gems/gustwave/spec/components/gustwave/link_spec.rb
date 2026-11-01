# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Link, type: :component do
  it "renders a link from the text argument" do
    render_inline(described_class.new("Read more", href: "/docs"))

    expect(page).to have_link("Read more", href: "/docs")
  end

  it "renders a link from a block" do
    render_inline(described_class.new(href: "/docs")) { "Block text" }

    expect(page).to have_link("Block text", href: "/docs")
  end

  it "composes with an icon in the block" do
    render_inline(described_class.new(href: "/stories", class: "inline-flex items-center")) do |link|
      link.helpers.safe_join([ "Read their stories", link.render(Gustwave::Icon.new(:arrow_right)) ])
    end

    expect(page).to have_selector("a.inline-flex.items-center[href='/stories'] svg")
    expect(page).to have_link("Read their stories")
  end

  it "is medium weight and blue by default" do
    render_inline(described_class.new("Read more", href: "/docs"))

    expect(page).to have_selector("a.font-medium.text-blue-600.dark\\:text-blue-500")
  end

  it "passes HTML attributes to the link" do
    render_inline(described_class.new("Read more", href: "/docs", id: "more", target: "_blank", data: { turbo: false }))

    expect(page).to have_selector("a#more[target='_blank'][data-turbo='false']")
  end

  it "lets the caller's classes win conflicts" do
    render_inline(described_class.new("Read more", href: "/docs", class: "text-blue-700"))

    expect(page).to have_selector("a.text-blue-700")
    expect(page).to have_no_selector("a.text-blue-600")
  end

  describe "underline" do
    it "underlines on hover by default" do
      render_inline(described_class.new("Read more", href: "/docs"))

      expect(page).to have_selector("a.hover\\:underline")
      expect(page).to have_no_selector("a.underline")
    end

    it "underlines until hovered for always" do
      render_inline(described_class.new("Read more", href: "/docs", underline: :always))

      expect(page).to have_selector("a.underline.hover\\:no-underline")
      expect(page).to have_no_selector("a.hover\\:underline")
    end

    it "renders no underline classes for none" do
      render_inline(described_class.new("Read more", href: "/docs", underline: :none))

      expect(page).to have_no_selector("a[class*='underline']")
    end
  end

  describe "none color" do
    it "renders no color or weight classes" do
      render_inline(described_class.new("Read more", href: "/docs", color: :none))

      expect(page).to have_link("Read more", href: "/docs")
      expect(page).to have_no_selector("a[class*='text-blue']")
      expect(page).to have_no_selector("a.font-medium")
    end

    it "keeps the underline" do
      render_inline(described_class.new("Read more", href: "/docs", color: :none))

      expect(page).to have_selector("a.hover\\:underline")
    end
  end
end
