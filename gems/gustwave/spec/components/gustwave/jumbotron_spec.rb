# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Jumbotron, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "section"

  it "renders a section with a container and the default classes" do
    render_inline(described_class.new) { "Content" }

    expect(page).to have_selector("section.bg-white.dark\\:bg-gray-900 > div.py-8.px-4.mx-auto.max-w-screen-xl.lg\\:py-16")
    expect(page).not_to have_selector("div.text-center")
  end

  it "renders the block content inside the container" do
    render_inline(described_class.new) { "<h1>Hero</h1>".html_safe }

    expect(page).to have_selector("section > div > h1", text: "Hero")
  end

  it "centers the content of the container when centered" do
    render_inline(described_class.new(centered: true)) { "Content" }

    expect(page).to have_selector("section > div.text-center", text: "Content")
    expect(page).not_to have_selector("section.text-center")
  end

  it "merges the container options and lets their classes win conflicts" do
    render_inline(described_class.new(container_options: { class: "py-24", id: "hero-container" })) { "Content" }

    expect(page).to have_selector("section > div#hero-container.py-24")
    expect(page).not_to have_selector("div.py-8")
    expect(page).to have_selector("div.px-4.mx-auto")
  end

  it "merges the caller's classes on the section" do
    render_inline(described_class.new(class: "relative isolate")) { "Content" }

    expect(page).to have_selector("section.relative.isolate.bg-white")
  end

  describe "background image" do
    def render_with_background_image(*args, jumbotron_options: {}, **options)
      render_inline(described_class.new(**jumbotron_options)) do |jumbotron|
        jumbotron.with_background_image(*args, **options)
        "Content"
      end
    end

    it "renders a decorative image behind the content, covering the section" do
      render_with_background_image("/hero.jpg")

      expect(page).to have_selector("section > img[src='/hero.jpg'][alt=''].absolute.inset-0.-z-10.size-full.object-cover.mix-blend-multiply")
      expect(page).to have_selector("section > img + div", text: "Content")
    end

    it "darkens the image with the section's gray background" do
      render_with_background_image("/hero.jpg")

      classes = page.find("section")[:class].split
      expect(classes).to include("relative", "isolate", "bg-gray-700", "dark:bg-gray-700")
      expect(classes).not_to include("bg-white", "dark:bg-gray-900")
    end

    it "passes the alt text and HTML attributes to the image and lets its classes win conflicts" do
      render_with_background_image("/hero.jpg", alt: "Conference hall", fetchpriority: "high", class: "object-none")

      expect(page).to have_selector("img[alt='Conference hall'][fetchpriority='high'].object-none")
      expect(page).not_to have_selector("img.object-cover")
    end

    it "lets the caller's classes change the tint" do
      render_with_background_image("/hero.jpg", jumbotron_options: { class: "bg-blue-900 dark:bg-blue-900" })

      classes = page.find("section")[:class].split
      expect(classes).to include("bg-blue-900", "dark:bg-blue-900")
      expect(classes).not_to include("bg-gray-700", "dark:bg-gray-700")
    end

    it "renders no image and keeps the white background without one" do
      render_inline(described_class.new) { "Content" }

      expect(page).not_to have_selector("img")
      expect(page.find("section")[:class].split).not_to include("relative", "isolate")
    end
  end
end
