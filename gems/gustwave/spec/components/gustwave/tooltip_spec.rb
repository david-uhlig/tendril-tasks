require "rails_helper"

RSpec.describe Gustwave::Tooltip, type: :component do
  it_behaves_like "a component with trigger options", prefix: "tooltip"

  it_behaves_like "a component with configurable html attributes", selector: "div.tooltip"

  it "renders a tooltip with the tooltip class" do
    render_inline(described_class.new("text"))
    expect(page).to have_selector("div.tooltip[role=tooltip]", text: "text", visible: :all)
  end

  it "lets the caller override the role" do
    render_inline(described_class.new("text", role: "status"))
    expect(page).to have_selector("div[role=status]", visible: :all)
  end

  it "renders an arrow by default" do
    render_inline(described_class.new("text"))
    expect(page).to have_selector("div.tooltip-arrow[data-popper-arrow]", visible: :all)
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
    it "describes the trigger by the tooltip" do
      expect(described_class.new("text", id: "tip").trigger_options)
        .to eq(
          "data-tooltip-target" => "tip", "data-tooltip-placement" => :top, "data-tooltip-trigger" => :hover,
          "aria-describedby" => "tip"
        )
    end

    it "marks the light scheme for Flowbite" do
      expect(described_class.new("text", scheme: :light).trigger_options).to include("data-tooltip-style" => "light")
    end

    it "doesn't mark the dark scheme" do
      expect(described_class.new("text").trigger_options).not_to have_key("data-tooltip-style")
    end
  end

  describe "styling" do
    it "fades in over 300ms by default" do
      render_inline(described_class.new("text"))
      expect(page).to have_selector("div.tooltip.duration-300", visible: :all)
    end

    it "replaces the duration with a class of the caller" do
      render_inline(described_class.new("text", class: "duration-500"))
      expect(page).to have_selector("div.tooltip.duration-500:not(.duration-300)", visible: :all)
    end

    it "styles the dark scheme without borders" do
      render_inline(described_class.new("text"))
      expect(page).to have_selector("div.tooltip.bg-gray-900:not(.border)", visible: :all)
      expect(page.find("[data-popper-arrow]", visible: :all)[:class]).not_to include("border")
    end

    it "borders the light scheme's arrow by the tooltip's placement" do
      render_inline(described_class.new("text", scheme: :light))
      expect(page).to have_selector("div.tooltip.bg-white.border", visible: :all)
      expect(page.find("[data-popper-arrow]", visible: :all)[:class].split).to contain_exactly(
        "tooltip-arrow", "after:hidden", "before:border-gray-200",
        "[[data-popper-placement^=top]>&]:before:border-b",
        "[[data-popper-placement^=top]>&]:before:border-r",
        "[[data-popper-placement^=right]>&]:before:border-b",
        "[[data-popper-placement^=right]>&]:before:border-l",
        "[[data-popper-placement^=bottom]>&]:before:border-t",
        "[[data-popper-placement^=bottom]>&]:before:border-l",
        "[[data-popper-placement^=left]>&]:before:border-t",
        "[[data-popper-placement^=left]>&]:before:border-r"
      )
    end

    it "hides the arrow's ::after in the dark scheme too" do
      render_inline(described_class.new("text"))
      expect(page.find("[data-popper-arrow]", visible: :all)[:class].split).to contain_exactly("tooltip-arrow", "after:hidden")
    end

    it "keeps only the tooltip class with scheme: :none" do
      render_inline(described_class.new("text", scheme: :none))
      expect(page.find("div[role=tooltip]", visible: :all)[:class]).to eq("tooltip")
    end
  end
end
