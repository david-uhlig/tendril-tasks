# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Popover, type: :component do
  it "renders an arrow by default" do
    render_inline(described_class.new("text"))
    expect(page).to have_selector("[data-popper-arrow]", visible: :all)
  end

  [ nil, true, "true" ].each do |arrow|
    it "renders an arrow with arrow: #{arrow.inspect}" do
      render_inline(described_class.new("text", arrow:))
      expect(page).to have_selector("[data-popper-arrow]", visible: :all)
    end
  end

  [ false, "false", "0" ].each do |arrow|
    it "renders no arrow with arrow: #{arrow.inspect}" do
      render_inline(described_class.new("text", arrow:))
      expect(page).not_to have_selector("[data-popper-arrow]", visible: :all)
    end
  end

  describe "#trigger_options" do
    subject(:component) { described_class.new("text", id: "pop") }

    it "targets the popover with the default placement and trigger" do
      expect(component.trigger_options).to eq(
        "data-popover-target" => "pop", "data-popover-placement" => :top, "data-popover-trigger" => :hover
      )
    end

    it "passes on a placement, trigger and offset" do
      expect(component.trigger_options(placement: :"bottom-start", trigger: :click, offset: 8))
        .to include("data-popover-placement" => :"bottom-start", "data-popover-trigger" => :click, "data-popover-offset" => 8)
    end

    it "raises for an unknown placement" do
      expect { component.trigger_options(placement: :above) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :above for :placement/)
    end

    it "falls back to the defaults when Gustwave isn't strict" do
      Gustwave.strict = false

      expect(component.trigger_options(placement: :above, trigger: :tap))
        .to include("data-popover-placement" => :top, "data-popover-trigger" => :hover)
    end
  end
end
