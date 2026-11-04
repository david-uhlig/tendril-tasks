require "rails_helper"

RSpec.describe Gustwave::SpeedDial, type: :component do
  def have_classes(*names)
    names.map { |name| "[class~='#{name}']" }.join
  end

  it_behaves_like "a component with configurable html attributes", selector: "div"

  it "renders the wrapper that Flowbite's dial script initializes" do
    render_inline(described_class.new)

    expect(page).to have_selector("div[data-dial-init].group")
  end

  it "places the wrapper at the bottom right by default" do
    render_inline(described_class.new)

    expect(page).to have_selector("div.fixed.end-6.bottom-6")
  end

  {
    bottom_right: %w[fixed end-6 bottom-6],
    bottom_left: %w[fixed start-6 bottom-6],
    top_right: %w[fixed end-6 top-6],
    top_left: %w[fixed start-6 top-6]
  }.each do |position, position_classes|
    it "places the wrapper with the #{position} classes" do
      render_inline(described_class.new(position:))

      expect(page).to have_selector("div#{have_classes(*position_classes)}")
    end
  end

  it "renders no fixed placement for position: :none" do
    render_inline(described_class.new(position: :none))

    expect(page).to have_selector("div[data-dial-init]")
    expect(page).not_to have_selector("div.fixed")
  end

  it "keeps the caller's data attributes on the wrapper" do
    render_inline(described_class.new(data: { controller: "x" }))

    expect(page).to have_selector("div[data-dial-init][data-controller='x']")
  end

  it "merges the caller's class into the wrapper classes" do
    render_inline(described_class.new(class: "my-custom-class"))

    expect(page).to have_selector("div.group.fixed.my-custom-class")
  end

  describe "menu id" do
    it "generates a menu id with the speed-dial prefix" do
      component = described_class.new
      render_inline(component)

      expect(component.menu_id).to match(/\Aspeed-dial-\w{8}\z/)
    end

    it "takes the menu id from id:" do
      component = described_class.new(id: "my-dial")
      render_inline(component)

      expect(component.menu_id).to eq("my-dial")
      expect(page).to have_selector("div#my-dial")
    end

    it "points the trigger at the menu" do
      render_inline(described_class.new(id: "my-dial")) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button[data-dial-toggle='my-dial'][aria-controls='my-dial']")
    end
  end

  describe "trigger" do
    it "renders the default trigger with the dial attributes" do
      render_inline(described_class.new(id: "my-dial"))

      expect(page).to have_selector("button[data-dial-toggle='my-dial'][aria-controls='my-dial'][aria-expanded='false']")
    end

    it "opens on hover by default" do
      render_inline(described_class.new)

      expect(page).to have_selector("button[data-dial-trigger='hover']")
    end

    it "opens on click when trigger_event: :click" do
      render_inline(described_class.new(trigger_event: :click))

      expect(page).to have_selector("button[data-dial-trigger='click']")
    end

    it "renders a custom trigger with the dial attributes" do
      render_inline(described_class.new(id: "my-dial")) do |dial|
        dial.with_trigger(icon: :edit, color: :dark)
      end

      expect(page).to have_selector("button[data-dial-toggle='my-dial'][aria-controls='my-dial'][aria-expanded='false']")
      expect(page).to have_selector("button svg")
    end

    it "keeps the dial attributes next to the caller's data and aria attributes" do
      render_inline(described_class.new(id: "my-dial")) do |dial|
        dial.with_trigger(data: { foo: 1 }, aria: { label: "x" })
      end

      expect(page).to have_selector("button[data-dial-toggle='my-dial'][data-foo='1']")
      expect(page).to have_selector("button[aria-controls='my-dial'][aria-expanded='false'][aria-label='x']")
    end

    it "lets the dial attributes win over the caller's conflicting data and aria keys" do
      render_inline(described_class.new(id: "my-dial")) do |dial|
        dial.with_trigger(data: { dial_toggle: "other" }, aria: { controls: "other" })
      end

      expect(page).to have_selector("button[data-dial-toggle='my-dial'][aria-controls='my-dial']")
    end

    it "renders the trigger before the menu in the DOM" do
      render_inline(described_class.new(id: "my-dial")) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("div[data-dial-init] > button + div#my-dial")
    end

    it "renders the square trigger with shape: :square" do
      render_inline(described_class.new(shape: :square))

      expect(page).to have_selector("button")
      expect(page).not_to have_selector("button.rounded-full")
    end
  end

  describe "menu" do
    it "renders the menu hidden, showing it with flex only when Flowbite removes hidden" do
      render_inline(described_class.new(id: "my-dial")) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("div#my-dial.hidden.not-\\[\\.hidden\\]\\:flex")
      expect(page).not_to have_selector("div#my-dial.flex")
    end

    it "lays the menu out as a column for up and down" do
      render_inline(described_class.new(id: "my-dial", direction: :down))

      expect(page).to have_selector("div#my-dial.flex-col")
    end

    it "lays the menu out as a row for left and right" do
      render_inline(described_class.new(id: "my-dial", direction: :left))

      expect(page).to have_selector("div#my-dial.flex-row")

      render_inline(described_class.new(id: "my-dial", direction: :right))

      expect(page).to have_selector("div#my-dial.flex-row")
    end
  end

  describe "direction" do
    it "opens bottom positions upwards by default" do
      render_inline(described_class.new(position: :bottom_right))

      expect(page).to have_selector("div.flex-col-reverse")
    end

    it "opens top positions downwards by default" do
      render_inline(described_class.new(position: :top_left))

      expect(page).to have_selector("div.flex-col:not(.flex-col-reverse)")
    end

    it "uses an explicit direction over the position's default" do
      render_inline(described_class.new(position: :top_right, direction: :up))

      expect(page).to have_selector("div.flex-col-reverse")
    end

    it "opens the wrapper to the left with flex-row-reverse" do
      render_inline(described_class.new(direction: :left))

      expect(page).to have_selector("div.flex-row-reverse")
    end
  end

  describe "shape" do
    it "renders square actions with shape: :square" do
      render_inline(described_class.new(shape: :square)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button.rounded-lg")
      expect(page).not_to have_selector("button.rounded-full")
    end
  end

  describe "label placement" do
    it "places tooltips to the left at right positions" do
      render_inline(described_class.new(position: :bottom_right)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button[data-tooltip-placement='left']")
    end

    it "places tooltips to the right at left positions" do
      render_inline(described_class.new(position: :bottom_left)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button[data-tooltip-placement='right']")
    end

    it "places tooltips above the actions for a sideways direction" do
      render_inline(described_class.new(position: :bottom_right, direction: :left)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button[data-tooltip-placement='top']")
    end

    it "places outside labels to the left at right positions" do
      render_inline(described_class.new(position: :top_right, label_display: :outside)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button span#{have_classes(*%w[end-full me-3 top-1/2 -translate-y-1/2])}", text: "Edit")
    end

    it "places outside labels to the right at left positions" do
      render_inline(described_class.new(position: :top_left, label_display: :outside)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button span#{have_classes(*%w[start-full ms-3 top-1/2 -translate-y-1/2])}", text: "Edit")
    end

    it "places outside labels above the actions for a sideways direction" do
      render_inline(described_class.new(direction: :right, label_display: :outside)) do |dial|
        dial.with_action("Edit", icon: :edit)
      end

      expect(page).to have_selector("button span#{have_classes(*%w[bottom-full mb-2 start-1/2 -translate-x-1/2])}", text: "Edit")
    end

    it "lets a single action override the label display" do
      render_inline(described_class.new) do |dial|
        dial.with_action("Edit", icon: :edit, label_display: :inside)
      end

      expect(page).to have_selector("button span.block", text: "Edit")
      expect(page).not_to have_selector("[role=tooltip]", visible: :all)
    end
  end
end
