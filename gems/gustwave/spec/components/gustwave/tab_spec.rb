require "rails_helper"

RSpec.describe Gustwave::Tab, type: :component do
  let(:classes) do
    {
      item: "item-class",
      tab: "tab-class",
      panel: "panel-class",
      states: { active: "active-class", inactive: "inactive-class", disabled: "disabled-class" },
      edge: "edge-class"
    }
  end

  describe "#apply_slot_context" do
    it "sets the selection of the tab" do
      tab = described_class.new("Profile")
      tab.apply_slot_context(selected: true, interactive: true, classes:)

      expect(tab.selected?).to be true

      render_inline(tab)

      expect(page.find("button")["aria-selected"]).to eq "true"
    end

    it "sets the classes of the list item, the trigger and the state" do
      tab = described_class.new("Profile")
      tab.apply_slot_context(selected: true, interactive: true, classes:)

      render_inline(tab)

      expect(page.find("li")["class"].split).to eq [ "item-class" ]
      trigger_classes = page.find("button")["class"].split
      expect(trigger_classes).to include("tab-class", "edge-class", "active-class")
      expect(trigger_classes).not_to include("inactive-class")
    end

    it "sets the classes of the panel" do
      tab = described_class.new("Profile")
      tab.apply_slot_context(selected: true, interactive: true, classes:)

      render_inline(tab) { |component| component.with_panel { "Content" } }

      expect(tab.panel_element).to include("panel-class")
    end

    it "treats the selection and interactivity as true only for true" do
      tab = described_class.new("Profile")
      tab.apply_slot_context(selected: "yes", interactive: "yes", classes:)

      expect(tab.selected?).to be false
    end

    it "ignores unknown keywords" do
      tab = described_class.new("Profile")

      expect {
        tab.apply_slot_context(selected: true, interactive: true, classes:, extra: 1)
      }.not_to raise_error
      expect(tab.selected?).to be true
    end
  end

  it "no longer has the configure methods that Tabs used to call" do
    expect(described_class.public_method_defined?(:configure_selection)).to be false
    expect(described_class.public_method_defined?(:configure_classes)).to be false
  end
end
