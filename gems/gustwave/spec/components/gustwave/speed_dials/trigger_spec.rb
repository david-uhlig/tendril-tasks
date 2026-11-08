require "rails_helper"

RSpec.describe Gustwave::SpeedDials::Trigger, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "button"

  it "labels the button with the default screen reader text" do
    I18n.with_locale(:en) { render_inline(described_class.new) }

    expect(page).to have_selector("button > span.sr-only", exact_text: "Open actions menu")
  end

  it "localizes the default screen reader text" do
    I18n.with_locale(:de) { render_inline(described_class.new) }

    expect(page).to have_selector("button > span.sr-only", exact_text: "Aktionsmenü öffnen")
  end

  it "replaces the default screen reader text with the text" do
    render_inline(described_class.new("Open quick actions"))

    expect(page).to have_selector("button > span.sr-only", exact_text: "Open quick actions")
    expect(page).not_to have_content("Open actions menu")
  end

  it "renders the plus icon with the rotate-on-hover classes" do
    render_inline(described_class.new)

    expect(page).to have_selector("button > svg.size-8.group-hover\\:rotate-45")
  end

  it "renders the block content instead of the icon" do
    render_inline(described_class.new) { "<b>Close</b>".html_safe }

    expect(page).to have_selector("button > b", exact_text: "Close")
    expect(page).not_to have_selector("button svg")
    expect(page).to have_selector("button > span.sr-only", exact_text: "Open actions menu")
  end

  it "renders a leading visual set through the slot in place of the plus icon" do
    render_inline(described_class.new) { |trigger| trigger.with_leading_visual_icon :edit, theme: :outline }

    expect(page).to have_selector("button > svg[fill='none']", count: 1)
    expect(page).not_to have_selector("button svg.group-hover\\:rotate-45")
  end

  it "renders no icon with icon: nil" do
    render_inline(described_class.new(icon: nil))

    expect(page).not_to have_selector("button svg")
  end

  it "renders a leading visual set before rendering" do
    component = described_class.new(icon: nil)
    component.with_leading_visual_icon :edit
    render_inline(component)

    expect(page).to have_selector("button > svg", count: 1)
  end

  it "renders a round button by default" do
    render_inline(described_class.new)

    expect(page).to have_selector("button.rounded-full")
  end

  it "renders a square button with shape: :square" do
    render_inline(described_class.new(shape: :square))

    expect(page).to have_selector("button")
    expect(page).not_to have_selector("button.rounded-full")
  end

  it "renders a button sized to 14 units" do
    render_inline(described_class.new)

    expect(page).to have_selector("button.size-14.justify-center")
  end

  it "renders no size classes from the button" do
    render_inline(described_class.new)

    expect(page).not_to have_selector("button.h-10")
    expect(page).not_to have_selector("button.px-5")
  end

  it "passes the data and aria attributes through" do
    render_inline(described_class.new(data: { foo: "bar" }, aria: { controls: "x" }))

    expect(page).to have_selector("button[data-foo='bar'][aria-controls='x']")
  end

  it "merges the caller's class with the button classes" do
    render_inline(described_class.new(class: "extra-class"))

    expect(page).to have_selector("button.extra-class.size-14.justify-center")
  end
end
