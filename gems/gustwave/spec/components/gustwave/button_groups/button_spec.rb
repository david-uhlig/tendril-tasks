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

  {
    xs: "h-4",
    sm: "h-4",
    md: "h-4",
    lg: "h-5",
    xl: "h-5"
  }.each do |size, icon_height|
    it "renders Flowbite's icon gap and icon box for a #{size} button with a leading icon" do
      component = described_class.new("Go", size:)
      component.apply_slot_context(group_position: :only)
      render_inline(component) { |button| button.with_leading_visual_icon :check }

      classes = page.find("button")["class"].split
      icon_classes = page.find("button svg")["class"].split

      expect(classes).to include("gap-2")
      expect(classes).not_to include("gap-1.5")
      expect(classes).not_to include("h-8", "h-9", "h-10", "h-12", "h-13")
      expect(icon_classes).to include(icon_height, "w-auto", "-mx-0.5")
    end
  end

  it "renders the outline color" do
    expect(classes_at(:only, color: :outline)).to include("border-gray-900")
  end
end
