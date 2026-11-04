# Components whose +trigger_options+ point the trigger's +aria-controls+ at
# the component, replacing the trigger's own, e.g. a click Popover and
# Drawer, through Gustwave::HtmlAttributesHelper#without_controls.
#
# @param trigger_options [Hash] arguments that make +trigger_options+ set +aria-controls+, e.g. +{ trigger: :click }+
# @param component_class [Class] component class to test (default `described_class`)
RSpec.shared_examples "a component controlling its target" do |trigger_options: {}, component_class: described_class|
  describe "#trigger_options aria-controls" do
    subject(:component) { component_class.new(id: "target") }

    it "points the trigger at the component" do
      expect(component.trigger_options(**trigger_options)).to include("aria-controls" => "target")
    end

    [
      { "aria-controls": "other" },
      { "aria-controls" => "other" },
      { aria: { controls: "other" } }
    ].each do |attributes|
      it "replaces the trigger's aria-controls given as #{attributes.inspect}" do
        options = component.trigger_options(**trigger_options, **attributes)

        expect(options.keys.map(&:to_s).count("aria-controls")).to eq(1)
        expect(options).to include("aria-controls" => "target")
        expect(options).not_to have_key(:aria)
      end
    end

    it "keeps the other keys of the trigger's aria hash" do
      expect(component.trigger_options(**trigger_options, aria: { controls: "other", label: "X" }))
        .to include("aria-controls" => "target", aria: { label: "X" })
    end
  end
end
