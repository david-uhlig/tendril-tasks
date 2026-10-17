# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::ParagraphComponent, type: :component do
  it "renders the text in a gray, relaxed paragraph" do
    render_inline described_class.new("Are you sure?")

    expect(page).to have_css("p.text-base.leading-relaxed.text-gray-500", text: "Are you sure?")
  end

  it "renders the block content" do
    render_inline(described_class.new) { "Read the <a href='/docs'>docs</a>".html_safe }

    expect(page).to have_css("p.text-base", text: "Read the docs")
    expect(page).to have_link("docs", href: "/docs")
  end

  it "merges a caller class" do
    render_inline described_class.new("Hi", class: "mb-4")

    expect(page).to have_css("p.mb-4.text-base.text-gray-500", text: "Hi")
  end

  it "lets a caller color override the default gray" do
    render_inline described_class.new("Hi", class: "text-gray-900")

    expect(page).to have_css("p.text-gray-900", text: "Hi")
    expect(page).to have_no_css("p.text-gray-500")
  end
end
