# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Paragraph, type: :component do
  it "renders a paragraph from the text argument" do
    render_inline(described_class.new("Some text"))

    expect(page).to have_selector("p", text: "Some text")
  end

  it "renders a paragraph from a block" do
    render_inline(described_class.new) { "Block text" }

    expect(page).to have_selector("p", text: "Block text")
  end

  it "is gray by default" do
    render_inline(described_class.new("Some text"))

    expect(page).to have_selector("p.text-gray-500.dark\\:text-gray-400")
  end

  it "renders no color classes for the none color" do
    render_inline(described_class.new("Some text", color: :none))

    expect(page).to have_selector("p", text: "Some text")
    expect(page).to have_no_selector("p[class*='text-gray']")
  end

  it "keeps the alignment for the none color" do
    render_inline(described_class.new("Some text", color: :none, align: :center))

    expect(page).to have_selector("p.text-center")
    expect(page).to have_no_selector("p[class*='text-gray']")
  end

  describe "align" do
    it "isn't aligned by default" do
      render_inline(described_class.new("Some text"))

      expect(page).to have_no_selector("p[class*='text-left']")
      expect(page).to have_no_selector("p[class*='text-center']")
      expect(page).to have_no_selector("p[class*='text-right']")
    end

    it "aligns left, mirrored for right-to-left text" do
      render_inline(described_class.new("Some text", align: :left))

      expect(page).to have_selector("p.text-left.rtl\\:text-right")
    end

    it "centers" do
      render_inline(described_class.new("Some text", align: :center))

      expect(page).to have_selector("p.text-center")
    end

    it "aligns right, mirrored for right-to-left text" do
      render_inline(described_class.new("Some text", align: :right))

      expect(page).to have_selector("p.text-right.rtl\\:text-left")
    end

    it "raises for an unknown align" do
      expect { described_class.new("Some text", align: :justify) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :justify for :align/)
    end

    it "falls back to no alignment for an unknown align when Gustwave isn't strict" do
      Gustwave.strict = false
      render_inline(described_class.new("Some text", align: :justify))

      expect(page).to have_selector("p.text-gray-500")
      expect(page).to have_no_selector("p[class*='text-left']")
      expect(page).to have_no_selector("p[class*='text-right']")
    end
  end

  it "lets the caller's classes win conflicts" do
    render_inline(described_class.new("Some text", class: "text-gray-900"))

    expect(page).to have_selector("p.text-gray-900")
    expect(page).to have_no_selector("p.text-gray-500")
  end

  it "passes HTML attributes through" do
    render_inline(described_class.new("Some text", id: "intro"))

    expect(page).to have_selector("p#intro", text: "Some text")
  end
end
