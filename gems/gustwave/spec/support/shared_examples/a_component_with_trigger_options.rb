# Components that attach to a trigger element through +trigger_options+, with
# a placement and a trigger event, e.g. Popover and Tooltip. +trigger_options+
# returns the trigger's own attributes too, and the component's attributes win
# over the trigger's.
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

    it "returns the trigger's other attributes as they are" do
      expect(component.trigger_options(class: "underline", data: { controller: "x" }))
        .to include(class: "underline", data: { controller: "x" }, "data-#{prefix}-target" => "target")
    end

    it "lets its own attributes win over the trigger's" do
      options = component.trigger_options("data-#{prefix}-target": "other")
      expect(options).to include("data-#{prefix}-target" => "target")
      expect(options.keys.count { it.to_s == "data-#{prefix}-target" }).to eq(1)

      options = component.trigger_options(**{ "data-#{prefix}-target" => "other" })
      expect(options).to include("data-#{prefix}-target" => "target")
      expect(options.keys.count { it.to_s == "data-#{prefix}-target" }).to eq(1)
    end

    it "attaches a rendered trigger" do
      render_inline(Gustwave::Button.new("Hover me", **component.trigger_options(data: { controller: "x" })))
      expect(page).to have_css("button[data-controller=x][data-#{prefix}-target=target]")
    end
  end
end
