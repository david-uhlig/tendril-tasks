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

    it "joins the trigger's own aria-describedby with the tooltip's id" do
      expect(described_class.new("text", id: "tip").trigger_options("aria-describedby": "help"))
        .to include("aria-describedby" => "help tip")
        .and(satisfy { !it.key?(:"aria-describedby") })
    end

    it "joins an aria-describedby given as a string key" do
      expect(described_class.new("text", id: "tip").trigger_options(**{ "aria-describedby" => "help" }))
        .to include("aria-describedby" => "help tip")
        .and(satisfy { it.keys.count { |key| key.to_s == "aria-describedby" } == 1 })
    end

    it "joins an aria-describedby within the aria hash and keeps the other aria attributes" do
      expect(described_class.new("text", id: "tip").trigger_options(aria: { describedby: "help", label: "Delete" }))
        .to include("aria-describedby" => "help tip", aria: { label: "Delete" })
    end

    it "drops an aria hash with only aria-describedby" do
      expect(described_class.new("text", id: "tip").trigger_options(aria: { describedby: "help" }))
        .not_to have_key(:aria)
    end

    it "joins a list of ids and doesn't repeat the tooltip's id" do
      expect(described_class.new("text", id: "tip").trigger_options("aria-describedby": [ "help hint", "tip" ]))
        .to include("aria-describedby" => "help hint tip")
    end

    it "keeps the trigger's own aria-describedby on a rendered button" do
      tooltip = described_class.new("text", id: "tip")
      render_inline(Gustwave::Button.new("Hover me", **tooltip.trigger_options("aria-describedby": "help", data: { controller: "x" })))
      expect(page).to have_selector("button[aria-describedby='help tip'][data-controller=x][data-tooltip-target=tip]")
    end

    it "marks the light tooltip for Flowbite" do
      expect(described_class.new("text", color: :light).trigger_options).to include("data-tooltip-style" => "light")
    end

    it "doesn't mark the dark tooltip" do
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

    it "styles the dark tooltip without borders" do
      render_inline(described_class.new("text"))
      expect(page).to have_selector("div.tooltip.bg-gray-900:not(.border)", visible: :all)
      expect(page.find("[data-popper-arrow]", visible: :all)[:class]).not_to include("border")
    end

    it "borders the light tooltip's arrow by the tooltip's placement" do
      render_inline(described_class.new("text", color: :light))
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

    it "hides the arrow's ::after of the dark tooltip too" do
      render_inline(described_class.new("text"))
      expect(page.find("[data-popper-arrow]", visible: :all)[:class].split).to contain_exactly("tooltip-arrow", "after:hidden")
    end

    it "keeps only the tooltip class with color: :none" do
      render_inline(described_class.new("text", color: :none))
      expect(page.find("div[role=tooltip]", visible: :all)[:class]).to eq("tooltip")
    end
  end
end
