require "rails_helper"

RSpec.describe Gustwave::SpeedDials::Action, type: :component do
  it_behaves_like "a component with configurable html attributes", "Edit", selector: "button"

  def have_classes(*names)
    names.map { |name| "[class~='#{name}']" }.join
  end

  context "with the tag" do
    it "renders a button of type button by default" do
      render_inline(described_class.new("Edit"))

      expect(page).to have_selector("button[type='button']")
    end

    it "renders an a element with its href and no type" do
      render_inline(described_class.new("Edit", tag: :a, href: "/edit"))

      expect(page).to have_selector("a[href='/edit']")
      expect(page).not_to have_selector("a[type]")
    end
  end

  context "with the tooltip label" do
    before do
      render_inline(described_class.new("Edit", icon: :edit))
    end

    it "renders the label as sr-only text inside the button" do
      expect(page).to have_selector("button span.sr-only", text: "Edit")
    end

    it "renders a tooltip sibling after the button" do
      expect(page).to have_selector("button + [role=tooltip]", text: "Edit", visible: :all)
    end

    it "points the button at the tooltip" do
      target = page.find("button")["data-tooltip-target"]

      expect(target).to be_present
      expect(page).to have_selector("[role=tooltip][id='#{target}']", visible: :all)
    end

    it "places the tooltip on the left by default" do
      expect(page).to have_selector("button[data-tooltip-placement='left']")
    end

    it "does not describe the button by the tooltip" do
      expect(page).not_to have_selector("button[aria-describedby]")
    end
  end

  context "with the inside label" do
    before do
      render_inline(described_class.new("Edit", icon: :edit, label_display: :inside))
    end

    it "renders the label inside the button with its classes" do
      expect(page).to have_selector("button span#{have_classes('block', 'mb-px', 'text-xs', 'font-medium')}", text: "Edit")
    end

    it "renders no tooltip" do
      expect(page).not_to have_selector("[role=tooltip]", visible: :all)
    end

    it "renders no sr-only label" do
      expect(page).not_to have_selector(".sr-only")
    end
  end

  context "with the outside label" do
    it "renders the label inside the button with its classes" do
      render_inline(described_class.new("Edit", icon: :edit, label_display: :outside))

      expect(page).to have_selector("button span#{have_classes('absolute', 'text-sm', 'font-medium', 'whitespace-nowrap')}", text: "Edit")
    end

    it "renders no tooltip" do
      render_inline(described_class.new("Edit", icon: :edit, label_display: :outside))

      expect(page).not_to have_selector("[role=tooltip]", visible: :all)
    end

    {
      left: %w[end-full me-3 top-1/2 -translate-y-1/2],
      right: %w[start-full ms-3 top-1/2 -translate-y-1/2],
      top: %w[bottom-full mb-2 start-1/2 -translate-x-1/2 rtl:translate-x-1/2],
      bottom: %w[top-full mt-2 start-1/2 -translate-x-1/2 rtl:translate-x-1/2]
    }.each do |placement, placement_classes|
      it "renders the #{placement} label placement classes" do
        render_inline(described_class.new("Edit", label_display: :outside, label_placement: placement))

        expect(page).to have_selector("button span#{have_classes(*placement_classes)}", text: "Edit")
      end
    end
  end

  it "renders the block content in place of the icon" do
    render_inline(described_class.new("Edit", icon: :edit)) { "<span class='custom-icon'>X</span>".html_safe }

    expect(page).to have_selector("button span.custom-icon")
    expect(page).not_to have_selector("svg")
  end

  it "renders the icon with the icon part classes" do
    render_inline(described_class.new("Edit", icon: :edit))

    expect(page).to have_selector("button svg[aria-hidden='true']")
    expect(page).to have_selector("button svg.size-6\\.5")
    expect(page).not_to have_selector("button svg.me-1\\.5")
  end

  it "renders a solid icon by default" do
    render_inline(described_class.new("Edit", icon: :edit))

    expect(page).to have_selector("button svg[fill='currentColor']")
  end

  it "renders the icon in the given theme" do
    render_inline(described_class.new("Edit", icon: :edit, icon_theme: :outline))

    expect(page).to have_selector("button svg[fill='none']")
  end

  it "renders a square shape" do
    render_inline(described_class.new("Edit", shape: :square))

    expect(page).to have_selector("button.rounded-lg")
    expect(page).not_to have_selector("button.rounded-full")
  end

  it "renders a round shape by default" do
    render_inline(described_class.new("Edit"))

    expect(page).to have_selector("button.rounded-full")
  end

  it "renders unstyled with color: :none" do
    render_inline(described_class.new("Edit", color: :none))

    expect(page).to have_selector("button")
    expect(page).not_to have_selector("button.flex")
    expect(page).not_to have_selector("button.bg-white")
    expect(page).not_to have_selector("button.shadow-xs")
  end
end
