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
        "data-popover-target" => "pop", "data-popover-placement" => :top, "data-popover-trigger" => :hover,
        "aria-describedby" => "pop"
      )
    end

    it "passes on an offset" do
      expect(component.trigger_options(offset: 8)).to include("data-popover-offset" => 8)
    end

    it "returns the trigger's other attributes as they are" do
      expect(component.trigger_options(class: "underline", data: { controller: "x" })).to include(
        "data-popover-target" => "pop", class: "underline", data: { controller: "x" }
      )
    end

    it "lets the popover's attributes win over the trigger's, without duplicate keys" do
      [ { "data-popover-target": "other" }, { "data-popover-target" => "other" } ].each do |attributes|
        options = component.trigger_options(**attributes)

        expect(options["data-popover-target"]).to eq("pop")
        expect(options.keys.map(&:to_s).count("data-popover-target")).to eq(1)
      end
    end

    it "renders a button that carries the trigger's attributes and the popover's" do
      render_inline(Gustwave::Button.new("Hover me", **component.trigger_options(data: { controller: "x" })))
      expect(page).to have_css("button[data-controller='x'][data-popover-target='pop']", text: "Hover me")
    end
  end

  describe "#trigger_options ARIA" do
    subject(:component) { described_class.new("text", id: "pop") }

    it "describes the trigger with a hover popover" do
      options = component.trigger_options

      expect(options).to include("aria-describedby" => "pop")
      expect(options.keys.map(&:to_s)).not_to include("aria-controls")
    end

    it "joins a hover popover with the trigger's own aria-describedby" do
      expect(component.trigger_options("aria-describedby": "help")).to include("aria-describedby" => "help pop")
    end

    it "joins a hover popover with the trigger's aria-describedby inside an aria hash" do
      options = component.trigger_options(aria: { describedby: "help", label: "X" })

      expect(options).to include("aria-describedby" => "help pop", aria: { label: "X" })
    end

    it "points a click popover's trigger at the popover with aria-controls" do
      options = component.trigger_options(trigger: :click)

      expect(options).to include("aria-controls" => "pop")
      expect(options.keys.map(&:to_s)).not_to include("aria-describedby")
    end

    it "replaces the trigger's own aria-controls with the popover's" do
      [ { "aria-controls": "other" }, { "aria-controls" => "other" }, { aria: { controls: "other" } } ].each do |attributes|
        options = component.trigger_options(trigger: :click, **attributes)

        expect(options.keys.map(&:to_s).count("aria-controls")).to eq(1)
        expect(options).to include("aria-controls" => "pop")
        expect(options).not_to have_key(:aria)
      end
    end

    it "keeps the trigger's own aria-describedby with a click popover" do
      expect(component.trigger_options(trigger: :click, "aria-describedby": "help")).to include("aria-describedby": "help")
    end
  end
end
