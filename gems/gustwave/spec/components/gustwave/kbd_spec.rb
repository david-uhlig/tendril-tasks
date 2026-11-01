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

  it "lays out keys that contain an icon as inline-flex items-center" do
    render_inline(described_class.new("Shift"))

    expect(page).to have_selector("kbd[class~='has-[svg]:inline-flex']")
    expect(page).to have_selector("kbd[class~='has-[svg]:items-center']")
  end

  it "tightens the padding of keys that contain an icon" do
    render_inline(described_class.new("Shift"))

    expect(page).to have_selector("kbd[class~='has-[svg]:px-1'][class~='has-[svg]:py-0.5']")
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
end
