require "rails_helper"

RSpec.describe TendrilTasks::Paragraph, type: :component do
  it "renders a large paragraph by default" do
    render_inline(described_class.new("Text"))

    expect(rendered_content).to have_selector("p.text-lg.lg\\:text-xl.text-gray-500.hyphens-auto[lang='de']", text: "Text")
  end

  it "renders block content" do
    render_inline(described_class.new) { "Read the <a href='/docs'>docs</a>.".html_safe }

    expect(rendered_content).to have_selector("p.text-gray-500", text: "Read the docs.")
    expect(rendered_content).to have_link("docs", href: "/docs")
  end

  it "lets a caller color class override the default gray" do
    render_inline(described_class.new("Text", class: "text-gray-100 dark:text-gray-100"))

    expect(rendered_content).to have_selector("p.text-gray-100.dark\\:text-gray-100", text: "Text")
    expect(rendered_content).to have_no_selector("p.text-gray-500")
  end

  it "renders no hyphenation or lang when hyphenated is false" do
    render_inline(described_class.new("Text", hyphenated: false))

    expect(rendered_content).to have_selector("p", text: "Text")
    expect(rendered_content).to have_no_selector("p.hyphens-auto")
    expect(rendered_content).to have_no_selector("p[lang]")
  end
end
