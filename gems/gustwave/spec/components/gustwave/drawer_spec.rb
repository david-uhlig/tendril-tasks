# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Drawer, type: :component do
  it_behaves_like "a text and block content renderer", selector: "div[tabindex='-1']"
  it_behaves_like "a component with configurable html attributes", selector: "div[tabindex='-1']"

  it "keeps a given id on the drawer, which targets itself" do
    render_inline(described_class.new("text", id: "info"))

    expect(page).to have_selector("div#info[tabindex='-1'][data-drawer-target='info']")
  end

  it "generates an id for the drawer" do
    render_inline(described_class.new("text"))

    expect(page).to have_selector("div[id^='drawer-'][data-drawer-target^='drawer-']")
  end

  it "renders the placement, backdrop and body scrolling config by default" do
    render_inline(described_class.new("text", id: "info"))

    expect(page).to have_selector("div#info[data-drawer-placement='left'][data-drawer-backdrop='true'][data-drawer-body-scrolling='false']")
    expect(page).not_to have_selector("div#info[data-drawer-edge]")
  end

  it "renders a backdrop config of false" do
    render_inline(described_class.new("text", id: "info", backdrop: false))

    expect(page).to have_selector("div#info[data-drawer-backdrop='false']")
  end

  it "renders a body scrolling config of true" do
    render_inline(described_class.new("text", id: "info", body_scrolling: true))

    expect(page).to have_selector("div#info[data-drawer-body-scrolling='true']")
  end

  it "renders the left placement classes" do
    render_inline(described_class.new("text", placement: :left))

    expect(page).to have_selector("div.-translate-x-full.left-0")
  end

  it "renders the right placement classes" do
    render_inline(described_class.new("text", placement: :right))

    expect(page).to have_selector("div.translate-x-full.right-0")
    expect(page).to have_selector("div[data-drawer-placement='right']")
  end

  it "renders the top placement classes" do
    render_inline(described_class.new("text", placement: :top))

    expect(page).to have_selector("div.-translate-y-full.top-0")
  end

  it "renders the bottom placement classes" do
    render_inline(described_class.new("text", placement: :bottom))

    expect(page).to have_selector("div.translate-y-full.bottom-0")
  end

  context "with an edge" do
    it "renders the edge config, offset and classes with placement: :bottom" do
      render_inline(described_class.new("text", placement: :bottom, edge: true))

      expect(page).to have_selector("div[data-drawer-edge='true'][data-drawer-edge-offset='bottom-[60px]']")
      expect(page).to have_selector("div.bottom-0.bottom-\\[60px\\].rounded-t-lg")
    end

    it "renders a custom edge offset as class and data attribute" do
      render_inline(described_class.new("text", placement: :bottom, edge: true, edge_offset: "bottom-[80px]"))

      expect(page).to have_selector("div[data-drawer-edge-offset='bottom-[80px]']")
      expect(page).to have_selector("div.bottom-0.bottom-\\[80px\\]")
    end

    it "raises an ArgumentError with a placement other than :bottom when strict" do
      expect { described_class.new("text", placement: :left, edge: true) }
        .to raise_error(ArgumentError, /placement: :bottom/)
    end

    it "drops the edge with a placement other than :bottom when not strict" do
      Gustwave.strict = false
      render_inline(described_class.new("text", placement: :left, edge: true))

      expect(page).not_to have_selector("div[data-drawer-edge]")
      expect(page).not_to have_selector("div.rounded-t-lg")
    end
  end

  it "renders no aria-labelledby without a header" do
    render_inline(described_class.new("text", id: "info"))

    expect(page).not_to have_selector("div[aria-labelledby]")
  end

  describe "#trigger_options" do
    subject(:component) { described_class.new(id: "info") }

    it "toggles by default, with ARIA for the dialog" do
      expect(component.trigger_options).to include(
        "data-drawer-toggle" => "info",
        "aria-controls" => "info",
        "aria-haspopup" => "dialog"
      )
    end

    it "shows with data-drawer-show and the same ARIA" do
      expect(component.trigger_options(action: :show)).to include(
        "data-drawer-show" => "info",
        "aria-controls" => "info",
        "aria-haspopup" => "dialog"
      )
    end

    it "hides with data-drawer-hide and no ARIA" do
      options = component.trigger_options(action: :hide)

      expect(options).to include("data-drawer-hide" => "info")
      expect(options.keys.map(&:to_s)).not_to include("aria-controls", "aria-haspopup")
    end

    it "raises for an unknown action when strict" do
      expect { component.trigger_options(action: :open) }
        .to raise_error(Gustwave::Options::UnknownValueError)
    end

    it "falls back to toggle for an unknown action when not strict" do
      Gustwave.strict = false

      expect(component.trigger_options(action: :open)).to include("data-drawer-toggle" => "info")
    end

    it "never carries a data-drawer-target, even when given one" do
      options = component.trigger_options("data-drawer-target": "x")

      expect(options.keys.map(&:to_s)).not_to include("data-drawer-target")
    end

    it "replaces a caller's data-drawer-show with its own id" do
      options = component.trigger_options("data-drawer-show": "other")

      expect(options.keys.map(&:to_s).count("data-drawer-show")).to eq(0)
      expect(options.keys.map(&:to_s).count("data-drawer-toggle")).to eq(1)
      expect(options).to include("data-drawer-toggle" => "info")
    end

    it "passes other attributes through" do
      expect(component.trigger_options(class: "underline", data: { controller: "x" }))
        .to include(class: "underline", data: { controller: "x" })
    end

    it "renders on a button" do
      render_inline(Gustwave::Buttons::Default.new("Open", **component.trigger_options))

      expect(page).to have_css("button[data-drawer-toggle=info][aria-controls=info][aria-haspopup=dialog]")
    end
  end

  describe ".trigger_options" do
    it "returns the trigger attributes for the id" do
      expect(described_class.trigger_options("info")).to include(
        "data-drawer-toggle" => "info",
        "aria-controls" => "info",
        "aria-haspopup" => "dialog"
      )
    end

    it "takes the same action as the instance method" do
      expect(described_class.trigger_options("info", action: :hide)).to include("data-drawer-hide" => "info")
    end
  end
end
