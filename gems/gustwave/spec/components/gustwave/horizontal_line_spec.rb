require "rails_helper"

RSpec.describe Gustwave::HorizontalLine, type: :component do
  it "renders a plain horizontal line" do
    render_inline(described_class.new)

    expect(rendered_content).to have_selector("hr.w-full.h-px")
    expect(rendered_content).to have_no_selector("div")
  end

  it "renders text in the middle of the line" do
    render_inline(described_class.new) do |component|
      component.with_visual_text "Hello!", class: "custom"
    end

    expect(rendered_content).to have_selector("div>hr + span.custom", text: "Hello!")
  end

  it "wraps HTML block content in a content block" do
    render_inline(described_class.new) { "<strong>Hi</strong>".html_safe }

    expect(rendered_content).to have_selector("div>hr + div>strong", text: "Hi")
    expect(rendered_content).to have_no_selector("span")
  end

  it "renders an svg in the middle of the line" do
    render_inline(described_class.new) do |component|
      component.with_visual_svg(class: "custom", data: { foo_bar: "baz" }) do
        '<svg xmlns="http://www.w3.org/2000/svg"><rect width="1" height="1"/></svg>'.html_safe
      end
    end

    expect(rendered_content).to have_selector(
      "div>hr + div.custom[aria-hidden='true'][data-foo-bar='baz']>svg>rect"
    )
  end
end
