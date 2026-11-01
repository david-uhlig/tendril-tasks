require "rails_helper"

RSpec.describe Gustwave::ButtonGroups::Button, type: :component do
  it_behaves_like "a button theme"

  with_options selector: "button[type='button']" do
    it_behaves_like "a text and block content renderer"
  end

  def classes_at(group_position, **options)
    component = described_class.new("Go", **options)
    component.apply_slot_context(group_position:)
    render_inline(component)
    page.find("button")["class"].split
  end

  it "renders all four corners rounded for a single button" do
    expect(classes_at(:only)).to include("rounded-lg", "border")
  end

  it "renders only the start corners for the first button" do
    classes = classes_at(:first)

    expect(classes).to include("rounded-s-lg", "border", "rounded-none")
    expect(classes).not_to include("rounded-lg")
  end

  it "renders only the end corners for the last button" do
    classes = classes_at(:last)

    expect(classes).to include("rounded-e-lg", "border", "rounded-none")
    expect(classes).not_to include("rounded-lg")
  end

  it "renders top and bottom borders without rounding for a middle button" do
    classes = classes_at(:middle)

    expect(classes).to include("border-y", "border-0", "rounded-none")
    expect(classes).not_to include("rounded-lg", "rounded-s-lg", "rounded-e-lg")
  end

  it "renders the group focus ring, not the standalone one" do
    classes = classes_at(:only)

    expect(classes).to include("focus:ring-2")
    expect(classes).not_to include("focus:ring-4")
  end

  it "renders the Flowbite md size" do
    classes = classes_at(:only)

    expect(classes).to include("px-4", "py-2", "text-sm", "font-medium")
    expect(classes).not_to include("h-10")
  end

  it "renders the outline color" do
    expect(classes_at(:only, color: :outline)).to include("border-gray-900")
  end
end
