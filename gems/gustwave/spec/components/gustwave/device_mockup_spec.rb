# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::DeviceMockup, type: :component do
  piece = {
    notch: "[class*='w-[148px]']",
    action_button: "[class*='top-[72px]']",
    volume_up_button: "[class*='top-[124px]']",
    volume_down_button: "[class*='top-[178px]']",
    power_button: "[class*='top-[142px]']",
    crown: "[class*='top-[40px]']",
    crown_button: "[class*='top-[88px]']",
    strap_top: "[class*='rounded-t-[2.5rem]']",
    strap_bottom: "[class*='rounded-b-[2.5rem]']",
    keyboard: "[class*='rounded-t-sm']",
    keyboard_notch: "[class*='w-[56px]']",
    chin: "[class*='h-[24px]']",
    stand: "[class*='h-[55px]']"
  }

  it "renders the block inside the screen" do
    render_inline(described_class.new) { "Screen content" }

    expect(page).to have_selector("div.overflow-hidden", text: "Screen content")
  end

  it "is a phone by default" do
    render_inline(described_class.new)

    expect(page).to have_selector("div[class*='border-[14px]'][class*='w-[300px]']")
    expect(page).to have_no_selector("div[class*='shadow-xl']")
  end

  {
    phone: %i[action_button volume_up_button volume_down_button power_button],
    iphone: %i[notch volume_up_button volume_down_button power_button],
    android: %i[notch action_button volume_up_button volume_down_button power_button],
    tablet: %i[action_button volume_up_button volume_down_button power_button],
    laptop: %i[keyboard keyboard_notch],
    desktop: %i[chin stand],
    smartwatch: %i[strap_top crown crown_button strap_bottom]
  }.each do |device, expected|
    it "renders only the #{device} pieces" do
      render_inline(described_class.new(device:))

      expected.each { |name| expect(page).to have_selector(piece.fetch(name)) }
      (piece.keys - expected).each { |name| expect(page).to have_no_selector(piece.fetch(name)) }
      expect(page.all("div").size).to eq(3 + expected.size)
    end
  end

  it "renders the keyboard notch inside the keyboard" do
    render_inline(described_class.new(device: :laptop))

    expect(page).to have_selector("#{piece[:keyboard]} #{piece[:keyboard_notch]}")
  end

  it "uses the light colors" do
    render_inline(described_class.new(color: :light))

    expect(page).to have_selector("div[class*='border-[14px]'].bg-gray-300")
    expect(page).to have_selector("#{piece[:action_button]}.bg-gray-300")
  end

  it "renders no colour outside the screen for the none color" do
    render_inline(described_class.new(color: :none))

    expect(page).to have_selector("div[class*='border-[14px]']")
    expect(page).to have_no_selector("div:not(.overflow-hidden)[class*='bg-gray-'], div[class*='border-gray-']")
  end

  it "renders only the frame and screen for the none device" do
    render_inline(described_class.new(device: :none)) { "Screen content" }

    expect(page.all("div").size).to eq(3)
    expect(page).to have_selector("div.overflow-hidden", text: "Screen content")
  end

  it "passes the caller's id and classes to the wrapper element" do
    render_inline(described_class.new(id: "demo", class: "my-8"))

    expect(page.first("div")[:id]).to eq("demo")
    expect(page.first("div")[:class]).to include("my-8")
  end

  it "keeps the caller's classes off the frame" do
    render_inline(described_class.new(id: "demo", class: "my-8"))

    expect(page).to have_no_selector("div[class*='border-[14px]'][class*='my-8']")
    expect(page).to have_no_selector("div[class*='border-[14px]'][id='demo']")
  end

  it "falls back to a phone for an unknown device when Gustwave isn't strict" do
    Gustwave.strict = false
    render_inline(described_class.new(device: :watch))

    expect(page).to have_selector("div[class*='border-[14px]'][class*='w-[300px]']")
    expect(page).to have_selector(piece[:action_button])
  end
end
