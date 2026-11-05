# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Progress, type: :component do
  it "renders a track and a fill" do
    render_inline(described_class.new(45))

    expect(page).to have_selector("div[role='progressbar']")
    expect(page).to have_selector("div[role='progressbar'] > div[style='width: 45%']")
  end

  it "clamps values above 100" do
    render_inline(described_class.new(120))

    expect(page).to have_selector("div[role='progressbar'] > div[style='width: 100%']")
  end

  it "clamps values below 0" do
    render_inline(described_class.new(-5))

    expect(page).to have_selector("div[role='progressbar'] > div[style='width: 0%']")
  end

  it "treats nil as 0" do
    render_inline(described_class.new(nil))

    expect(page).to have_selector("div[role='progressbar'] > div[style='width: 0%']")
  end

  it "keeps decimal values" do
    render_inline(described_class.new(45.5))

    expect(page).to have_selector("div[role='progressbar'] > div[style='width: 45.5%']")
  end

  it "sets the progressbar role and the value attributes" do
    render_inline(described_class.new(45))

    expect(page).to have_selector("div[role='progressbar'][aria-valuenow='45'][aria-valuemin='0'][aria-valuemax='100']")
  end

  it "adds the caller's aria attributes and keeps aria-valuenow" do
    render_inline(described_class.new(45, aria: { label: "Upload" }))

    expect(page).to have_selector("div[role='progressbar'][aria-label='Upload'][aria-valuenow='45']")
  end

  it "lets the caller override aria-valuenow" do
    render_inline(described_class.new(45, aria: { valuenow: 10 }))

    expect(page).to have_selector("div[role='progressbar'][aria-valuenow='10'][aria-valuemin='0'][aria-valuemax='100']")
  end

  { sm: "h-1.5", md: "h-2.5", lg: "h-4", xl: "h-6" }.each do |size, height_class|
    it "gives the track and the fill the #{size} height" do
      render_inline(described_class.new(45, size:))

      track = page.find("div[role='progressbar']")
      expect(track[:class].split).to include(height_class)
      expect(track.find(:xpath, "./div")[:class].split).to include(height_class)
    end
  end

  it "renders block content inside the fill" do
    render_inline(described_class.new(45)) { "45%" }

    expect(page).to have_selector("div[role='progressbar'] > div[style='width: 45%']", text: "45%")
  end

  it "makes the track and the fill auto height when there is block content" do
    render_inline(described_class.new(45)) { "45%" }

    expect(page).to have_selector("div[role='progressbar'].h-auto")
    expect(page).to have_selector("div[role='progressbar'] > div.h-auto")
    expect(page).to have_no_selector("div[role='progressbar'].h-2\\.5")
    expect(page).to have_no_selector("div[role='progressbar'] > div.h-2\\.5")
  end

  it "renders content set with with_content inside the fill" do
    render_inline(described_class.new(45).with_content("45%"))

    expect(page).to have_selector("div[role='progressbar'].h-auto")
    expect(page).to have_selector("div[role='progressbar'] > div.h-auto", text: "45%")
    expect(page).to have_no_selector("div[role='progressbar'].h-2\\.5")
    expect(page).to have_no_selector("div[role='progressbar'] > div.h-2\\.5")
  end

  it "keeps the size height without content" do
    render_inline(described_class.new(45))

    expect(page).to have_no_selector("div[role='progressbar'].h-auto")
    expect(page).to have_no_selector("div[role='progressbar'] > div.h-auto")
  end

  it "lets fill_options class set another colour" do
    render_inline(described_class.new(45, fill_options: { class: "bg-teal-500" }))

    expect(page).to have_selector("div[role='progressbar'] > div.bg-teal-500")
    expect(page).to have_no_selector("div[role='progressbar'] > div.bg-blue-600")
  end

  it "keeps the fill style and adds the width" do
    render_inline(described_class.new(45, fill_options: { style: "transition: width 1s" }))

    expect(page).to have_selector("div[role='progressbar'] > div[style='transition: width 1s; width: 45%']")
  end

  it_behaves_like "a component with configurable html attributes", selector: "div[role='progressbar']"
end
