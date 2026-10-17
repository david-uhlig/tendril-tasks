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

  it_behaves_like "a component with trigger options", prefix: "popover"

  describe "#trigger_options" do
    subject(:component) { described_class.new("text", id: "pop") }

    it "targets the popover" do
      expect(component.trigger_options).to eq(
        "data-popover-target" => "pop", "data-popover-placement" => :top, "data-popover-trigger" => :hover
      )
    end

    it "passes on an offset" do
      expect(component.trigger_options(offset: 8)).to include("data-popover-offset" => 8)
    end
  end
end
