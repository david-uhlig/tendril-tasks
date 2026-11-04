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
  it_behaves_like "a component controlling its target", trigger_options: { trigger: :click }
  it_behaves_like "a text and block content renderer", selector: "div[role='tooltip']"
  it_behaves_like "a component with configurable html attributes", selector: "div[role='tooltip']"

  context "with a text argument" do
    before(:each) do
      render_inline(described_class.new("Helpful hint"))
    end

    it "renders the popover with the tooltip role" do
      expect(page).to have_selector("div[role='tooltip']", text: "Helpful hint")
    end

    it "marks the element as a popover" do
      expect(page).to have_selector("div[data-popover]")
    end

    it "generates an id for the popover" do
      expect(page).to have_selector("div[role='tooltip'][id^='popover-']")
    end
  end

  it "keeps a given id" do
    render_inline(described_class.new("text", id: "pop"))

    expect(page).to have_selector("div#pop[role='tooltip']")
  end

  it "takes a role override" do
    render_inline(described_class.new("text", role: "dialog"))

    expect(page).to have_selector("div[role='dialog']")
    expect(page).not_to have_selector("div[role='tooltip']")
  end

  describe "#trigger_options" do
    subject(:component) { described_class.new("text", id: "pop") }

    it "passes on an offset" do
      expect(component.trigger_options(offset: 8)).to include("data-popover-offset" => 8)
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

    it "keeps the trigger's own aria-describedby with a click popover" do
      expect(component.trigger_options(trigger: :click, "aria-describedby": "help")).to include("aria-describedby": "help")
    end
  end
end
