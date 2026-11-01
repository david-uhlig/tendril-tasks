# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Card, type: :component do
  it "renders a div with the base classes" do
    render_inline(described_class.new) { "Some text" }

    expect(page).to have_selector("div.max-w-sm.bg-white.border.border-gray-200.rounded-lg.shadow-sm.dark\\:bg-gray-800.dark\\:border-gray-700")
  end

  it "renders the content inside a padded body" do
    render_inline(described_class.new) { "Some text" }

    expect(page).to have_selector("div > div.p-6", text: "Some text")
  end

  it "renders no body without content" do
    render_inline(described_class.new)

    expect(page).to have_no_selector("div.p-6")
  end

  describe "link" do
    it "renders an a with the href and the link classes" do
      render_inline(described_class.new(tag: :a, href: "/x")) { "Some text" }

      expect(page).to have_selector("a[href='/x'].block.hover\\:bg-gray-100.dark\\:hover\\:bg-gray-700", text: "Some text")
    end

    it "renders no link classes on a div" do
      render_inline(described_class.new) { "Some text" }

      expect(page).to have_no_selector("div[class*='hover:']")
      expect(page).to have_no_selector("div.block")
    end

    it "rejects an unknown tag when Gustwave is strict" do
      expect { render_inline(described_class.new(tag: :section)) }.to raise_error(Gustwave::Options::UnknownValueError)
    end

    it "falls back to a div for an unknown tag when Gustwave isn't strict" do
      Gustwave.strict = false
      render_inline(described_class.new(tag: :section)) { "Some text" }

      expect(page).to have_selector("div.max-w-sm", text: "Some text")
      expect(page).to have_no_selector("section")
    end
  end

  describe "image" do
    it "renders the image before the body" do
      render_inline(described_class.new) do |card|
        card.with_image("/a.png", alt: "A")
        "Some text"
      end

      expect(page).to have_selector("img[alt='A'].rounded-t-lg[src='/a.png']")
      expect(page).to have_selector("div > img + div.p-5", text: "Some text")
    end

    it "pads the body less than without an image" do
      render_inline(described_class.new) do |card|
        card.with_image("/a.png", alt: "A")
        "Some text"
      end

      expect(page).to have_selector("div.p-5", text: "Some text")
      expect(page).to have_no_selector("div.p-6")
    end

    it "wraps the image in a link with href" do
      render_inline(described_class.new) do |card|
        card.with_image("/a.png", alt: "A", href: "/x")
        "Some text"
      end

      expect(page).to have_selector("a[href='/x'] > img[alt='A']")
    end

    it "requires alt text" do
      expect {
        render_inline(described_class.new) do |card|
          card.with_image("/a.png")
          "Some text"
        end
      }.to raise_error(ArgumentError)
    end

    it "renders no body for an image-only card" do
      render_inline(described_class.new) do |card|
        card.with_image("/a.png", alt: "")
        nil
      end

      expect(page).to have_selector("img[alt='']")
      expect(page).to have_no_selector("div.p-5")
      expect(page).to have_no_selector("div.p-6")
    end
  end

  describe "horizontal" do
    it "lays the root out as a row from md up without a max width of sm" do
      render_inline(described_class.new(horizontal: true)) { "Some text" }

      expect(page).to have_selector("div.flex.md\\:flex-row.md\\:max-w-xl.max-w-none")
      expect(page).to have_no_selector("div.max-w-sm")
    end

    it "drops block from a link card" do
      render_inline(described_class.new(tag: :a, href: "/x", horizontal: true)) { "Some text" }

      expect(page).to have_selector("a.flex.md\\:flex-row")
      expect(page).to have_no_selector("a.block")
      expect(page).to have_selector("a.hover\\:bg-gray-100")
    end

    it "styles the image for the row layout" do
      render_inline(described_class.new(horizontal: true)) do |card|
        card.with_image("/a.png", alt: "A")
        "Some text"
      end

      expect(page).to have_selector("img.object-cover.w-full.h-96.md\\:h-auto.md\\:w-48.md\\:rounded-none.md\\:rounded-s-lg")
    end

    it "pads the body for the row layout and drops p-5" do
      render_inline(described_class.new(horizontal: true)) do |card|
        card.with_image("/a.png", alt: "A")
        "Some text"
      end

      expect(page).to have_selector("div.flex.flex-col.justify-between.p-4.leading-normal", text: "Some text")
      expect(page).to have_no_selector("div.p-5")
    end
  end

  describe "class conflicts" do
    it "lets the horizontal flex win over the link block" do
      render_inline(described_class.new(tag: :a, href: "/x", horizontal: true)) { "Some text" }

      expect(page).to have_selector("a.flex")
      expect(page).to have_no_selector("a.block")
    end

    it "lets the horizontal body p-4 win over the image body p-5 and the base p-6" do
      render_inline(described_class.new(horizontal: true)) do |card|
        card.with_image("/a.png", alt: "A")
        "Some text"
      end

      expect(page).to have_selector("div.p-4")
      expect(page).to have_no_selector("div.p-5")
      expect(page).to have_no_selector("div.p-6")
    end

    it "lets the horizontal max-w-none win over the base max-w-sm" do
      render_inline(described_class.new(horizontal: true)) { "Some text" }

      expect(page).to have_selector("div.max-w-none")
      expect(page).to have_no_selector("div.max-w-sm")
    end
  end

  describe "configure_body" do
    it "adds the caller's classes to the body" do
      render_inline(described_class.new) do |card|
        card.configure_body(class: "px-0 pb-10 pt-4")
        "Some text"
      end

      expect(page).to have_selector("div.px-0.pb-10.pt-4", text: "Some text")
    end

    it "lets the caller's classes win conflicts on the body" do
      render_inline(described_class.new) do |card|
        card.configure_body(class: "p-0")
        "Some text"
      end

      expect(page).to have_selector("div.p-0", text: "Some text")
      expect(page).to have_no_selector("div.p-6")
    end

    it "keeps the body classes that the caller doesn't override" do
      render_inline(described_class.new) do |card|
        card.configure_body(id: "body")
        "Some text"
      end

      expect(page).to have_selector("div#body.p-6", text: "Some text")
    end
  end

  it "lets the caller's classes win on the root" do
    render_inline(described_class.new(class: "max-w-md")) { "Some text" }

    expect(page).to have_selector("div.max-w-md")
    expect(page).to have_no_selector("div.max-w-sm")
  end

  it "passes HTML attributes through" do
    render_inline(described_class.new(id: "product")) { "Some text" }

    expect(page).to have_selector("div#product.max-w-sm")
  end
end
