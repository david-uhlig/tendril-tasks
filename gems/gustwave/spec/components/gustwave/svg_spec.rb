require "rails_helper"

RSpec.describe Gustwave::Svg, type: :component do
  # Ships with aria-hidden="true", like most of Gustwave's icons
  let(:source) { "gustwave/icons/outline/close.svg" }

  def svg
    Nokogiri::HTML.fragment(rendered_content).at_css("svg")
  end

  describe "from a source file" do
    it "renders the file" do
      render_inline(described_class.new(source))

      expect(svg["viewbox"] || svg["viewBox"]).to eq "0 0 24 24"
      expect(svg["aria-hidden"]).to eq "true"
    end

    it "renders html attributes inline_svg doesn't know" do
      render_inline(described_class.new(source, name: "close", role: "button", tabindex: 0))

      expect(svg["name"]).to eq "close"
      expect(svg["role"]).to eq "button"
      expect(svg["tabindex"]).to eq "0"
    end

    it "renders the id, style and data attributes" do
      render_inline(described_class.new(source, id: "close-icon", style: "color: red", data: { foo: "bar" }))

      expect(svg["id"]).to eq "close-icon"
      expect(svg["style"]).to eq "color: red"
      expect(svg["data-foo"]).to eq "bar"
    end

    it "renders the class attribute" do
      render_inline(described_class.new(source, class: "h-6 w-6"))

      expect(svg["class"]).to eq "h-6 w-6"
    end

    it "renders an aria-label and no longer hides the svg" do
      render_inline(described_class.new(source, aria: { label: "Close" }))

      expect(svg["aria-label"]).to eq "Close"
      expect(svg["aria-hidden"]).to be_nil
      expect(svg["role"]).to be_nil
    end

    it "accepts the aria-label as a flat attribute" do
      render_inline(described_class.new(source, "aria-label": "Close"))

      expect(svg["aria-label"]).to eq "Close"
      expect(svg["aria-hidden"]).to be_nil
    end

    it "no longer hides the svg given aria-labelledby" do
      render_inline(described_class.new(source, aria: { labelledby: "some-label" }))

      expect(svg["aria-labelledby"]).to eq "some-label"
      expect(svg["aria-hidden"]).to be_nil
    end

    it "keeps an aria-hidden the caller sets along with a label" do
      render_inline(described_class.new(source, aria: { label: "Close", hidden: true }))

      expect(svg["aria-label"]).to eq "Close"
      expect(svg["aria-hidden"]).to eq "true"
    end

    it "keeps inline_svg's aria flag, labelling the svg by its title" do
      render_inline(described_class.new(source, aria: true, title: "Close"))

      expect(svg["role"]).to eq "img"
      expect(svg["aria-labelledby"]).to eq svg.at_css("title")["id"]
      expect(svg.at_css("title").text).to eq "Close"
    end

    it "renders an empty svg for a missing file" do
      render_inline(described_class.new("gustwave/icons/outline/missing.svg", role: "img"))

      expect(svg).to be_present
      expect(svg["role"]).to eq "img"
    end
  end

  describe "from block content" do
    it "renders the svg with html attributes" do
      render_inline(described_class.new(class: "h-4", aria: { label: "Dot" })) do
        '<svg aria-hidden="true" viewBox="0 0 2 2"><circle r="1"/></svg>'.html_safe
      end

      expect(svg["class"]).to eq "h-4"
      expect(svg["aria-label"]).to eq "Dot"
      expect(svg["aria-hidden"]).to be_nil
      expect(svg.at_css("circle")).to be_present
    end
  end

  describe "through Gustwave::Icon" do
    it "labels the icon for screen readers" do
      render_inline(Gustwave::Icon.new(:close, aria: { label: "Close" }))

      expect(svg["aria-label"]).to eq "Close"
      expect(svg["aria-hidden"]).to be_nil
    end

    it "keeps the icon decorative without a label" do
      render_inline(Gustwave::Icon.new(:close))

      expect(svg["aria-hidden"]).to eq "true"
    end
  end
end
