# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Kbd, type: :component do
  it "renders a kbd from the text argument" do
    render_inline(described_class.new("Shift"))

    expect(page).to have_selector("kbd", text: "Shift")
  end

  it "renders a kbd from a block" do
    render_inline(described_class.new) { "Block text" }

    expect(page).to have_selector("kbd", text: "Block text")
  end

  it "prefers the text argument over the block" do
    render_inline(described_class.new("Argument text")) { "Block text" }

    expect(page).to have_selector("kbd", text: "Argument text")
    expect(page).to have_no_text("Block text")
  end

  it "has Flowbite's base classes" do
    render_inline(described_class.new("Shift"))

    expect(page).to have_selector("kbd.px-2.py-1\\.5.text-xs.font-semibold.rounded-lg.bg-gray-100")
  end

  it "lets the caller's classes win conflicts" do
    render_inline(described_class.new("Space", class: "px-4"))

    expect(page).to have_selector("kbd.px-4", text: "Space")
    expect(page).to have_no_selector("kbd.px-2")
  end

  it "passes HTML attributes through" do
    render_inline(described_class.new("Shift", id: "shift-key"))

    expect(page).to have_selector("kbd#shift-key", text: "Shift")
  end

  it "renders an icon key from a block" do
    render_inline(described_class.new) do |kbd|
      kbd.helpers.safe_join([
        kbd.render(Gustwave::Icon.new(:caret_up, theme: :solid, aria: { hidden: true })),
        kbd.helpers.tag.span("Arrow key up", class: "sr-only")
      ])
    end

    expect(page).to have_selector("kbd svg[aria-hidden='true']")
    expect(page).to have_selector("kbd span.sr-only", text: "Arrow key up")
  end

  it "keeps text keys inline" do
    render_inline(described_class.new("Shift"))

    expect(page).to have_no_selector("kbd.inline-flex")
  end

  describe "#with_icon" do
    it "renders the icon and a screen reader label" do
      render_inline(described_class.new) { |kbd| kbd.with_icon(:caret_up, label: "Arrow key up") }

      expect(page).to have_selector("kbd svg[aria-hidden='true']")
      expect(page).to have_selector("kbd span.sr-only", text: "Arrow key up")
    end

    it "lays the key out as inline-flex items-center" do
      render_inline(described_class.new) { |kbd| kbd.with_icon(:caret_up, label: "Arrow key up") }

      expect(page).to have_selector("kbd.inline-flex.items-center")
    end

    it "sizes the icon through the visual part" do
      render_inline(described_class.new) { |kbd| kbd.with_icon(:caret_up, label: "Arrow key up") }

      expect(page).to have_selector("kbd svg.h-4.w-4[class~='-m-0.75']")
    end

    it "defaults to the solid theme" do
      render_inline(described_class.new) { |kbd| kbd.with_icon(:caret_up, label: "Arrow key up") }

      expect(page).to have_selector("kbd svg[fill='currentColor']")
    end

    it "lets the caller choose the theme" do
      render_inline(described_class.new) { |kbd| kbd.with_icon(:caret_up, label: "Arrow key up", theme: :outline) }

      expect(page).to have_no_selector("kbd svg[fill='currentColor']")
    end

    it "requires a label" do
      expect do
        render_inline(described_class.new) { |kbd| kbd.with_icon(:caret_up) }
      end.to raise_error(ArgumentError, /label/)
    end

    it "keeps the label of every icon" do
      render_inline(described_class.new) do |kbd|
        kbd.with_icon(:caret_up, label: "Up")
        kbd.with_icon(:caret_down, label: "Down")
      end

      expect(page).to have_selector("kbd svg", count: 2)
      expect(page).to have_selector("kbd span.sr-only", text: "Up")
      expect(page).to have_selector("kbd span.sr-only", text: "Down")
    end

    it "renders beside the text argument" do
      render_inline(described_class.new("K")) { |kbd| kbd.with_icon(:caret_up, label: "Command") }

      expect(page).to have_selector("kbd svg")
      expect(page).to have_selector("kbd span.sr-only", text: "Command")
      expect(page).to have_selector("kbd", text: "K")
    end
  end

  describe "visual slots" do
    it "renders a leading icon without a label" do
      render_inline(described_class.new("K")) { |kbd| kbd.with_leading_visual_icon(:caret_up, theme: :solid) }

      expect(page).to have_selector("kbd.inline-flex svg.h-4.w-4")
      expect(page).to have_no_selector("kbd span.sr-only")
    end

    it "supports indicators" do
      render_inline(described_class.new("K")) { |kbd| kbd.with_leading_visual_indicator }

      expect(page).to have_selector("kbd.inline-flex", text: "K")
    end
  end
end
