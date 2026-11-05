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
end
