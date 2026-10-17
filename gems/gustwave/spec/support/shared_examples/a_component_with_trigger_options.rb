# Components that attach to a trigger element through +trigger_options+, with
# a placement and a trigger event, e.g. Popover and Tooltip.
#
# @param prefix [String] the prefix of the data attributes, e.g. "popover" for +data-popover-target+
# @param component_class [Class] component class to test (default `described_class`)
RSpec.shared_examples "a component with trigger options" do |prefix:, component_class: described_class|
  describe "#trigger_options" do
    subject(:component) { component_class.new("text", id: "target") }

    it "targets the component with the default placement and trigger" do
      expect(component.trigger_options).to include(
        "data-#{prefix}-target" => "target",
        "data-#{prefix}-placement" => :top,
        "data-#{prefix}-trigger" => :hover
      )
    end

    it "passes on a placement and trigger" do
      expect(component.trigger_options(placement: :"bottom-start", trigger: :click))
        .to include("data-#{prefix}-placement" => :"bottom-start", "data-#{prefix}-trigger" => :click)
    end

    it "raises for an unknown placement" do
      expect { component.trigger_options(placement: :above) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :above for :placement/)
    end

    it "falls back to the defaults when Gustwave isn't strict" do
      Gustwave.strict = false

      expect(component.trigger_options(placement: :above, trigger: :tap))
        .to include("data-#{prefix}-placement" => :top, "data-#{prefix}-trigger" => :hover)
    end
  end
end
