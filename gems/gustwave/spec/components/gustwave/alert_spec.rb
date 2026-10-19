# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Alert, type: :component do
  # The constructor convention is checked for all components in
  # constructor_convention_spec.rb
  it_behaves_like "a text and block content renderer", selector: "div[role='alert']"
  it_behaves_like "a component with configurable html attributes", selector: "div[role='alert']"

  context "with default options" do
    before(:each) { render_inline(described_class.new("content")) }

    it "renders an alert" do
      expect(page).to have_selector("div[role='alert']", text: "content")
    end

    it "renders the blue color" do
      expect(page).to have_selector("div.bg-blue-50")
    end

    it "renders no flex, alignment, border or id" do
      expect(page).not_to have_selector("div.flex")
      expect(page).not_to have_selector("div.items-center")
      expect(page).not_to have_selector("div.border")
      expect(page).not_to have_selector("div[id]")
    end
  end

  describe "colors" do
    {
      red: "red-50",
      green: "green-50",
      yellow: "yellow-50",
      dark: "gray-50"
    }.each do |color, background|
      it "renders the #{color} color" do
        render_inline(described_class.new("content", color:))

        expect(page).to have_selector("div.bg-#{background}")
      end
    end

    it "renders no color classes for :none" do
      render_inline(described_class.new("content", color: :none))

      expect(page).to have_selector("div[role='alert']")
      expect(page).not_to have_selector("div.p-4")
      expect(page).not_to have_selector("div[class*='bg-']")
    end
  end

  describe "border" do
    it "renders a border in the color" do
      render_inline(described_class.new("content", color: :red, border: true))

      expect(page).to have_selector("div.border-red-300")
    end

    it "renders a gray border for :dark" do
      render_inline(described_class.new("content", color: :dark, border: true))

      expect(page).to have_selector("div.border-gray-300")
    end
  end

  describe "accent" do
    it "renders a top border" do
      render_inline(described_class.new("content", accent: true))

      expect(page).to have_selector("div.border-t-4")
      expect(page).not_to have_selector("div.rounded-lg")
    end

    it "wins over border" do
      render_inline(described_class.new("content", border: true, accent: true))

      expect(page).to have_selector("div.border-t-4")
      expect(page).not_to have_selector("div.border")
    end
  end

  describe "title" do
    it "renders before the content" do
      render_inline(described_class.new("content", title: "Heads up!"))

      expect(page).to have_selector("div > span.font-medium", text: "Heads up!")
      expect(page.text).to eq("Heads up! content")
    end
  end

  describe "icon" do
    it "renders a flex alert with the icon before the body" do
      render_inline(described_class.new("content", title: "Title")) { |alert| alert.with_icon(label: "Info") }

      expect(page).to have_selector("div.flex[role='alert']")
      expect(page).to have_selector("div > svg[aria-hidden='true']")
      expect(page).to have_selector("div > span.sr-only", text: "Info")
      expect(page).to have_selector("div > div > span.font-medium", text: "Title")
      expect(page).to have_selector("div > div", text: "content")
    end

    it "renders no label without one" do
      render_inline(described_class.new("content")) { |alert| alert.with_icon }

      expect(page).to have_selector("svg")
      expect(page).not_to have_selector("span.sr-only")
    end

    it "top-aligns the icon for align: :start" do
      render_inline(described_class.new("content", align: :start)) { |alert| alert.with_icon }

      expect(page).to have_selector("div.flex")
      expect(page).not_to have_selector("div.items-center")
      expect(page).to have_selector("svg.mt-\\[2px\\]")
    end
  end

  describe "dismiss button" do
    it_behaves_like "a component with a dismiss button slot", "content", id_prefix: "alert"

    it "renders the icon at the size of Flowbite's close icon" do
      render_inline(described_class.new("content", color: :red), &:with_dismiss_button)

      expect(page).to have_selector("div.flex > button > svg.w-6.h-6")
    end

    it "renders the body in medium weight" do
      render_inline(described_class.new("content"), &:with_dismiss_button)

      expect(page).to have_selector("div.flex > div.font-medium", text: "content")
    end

    it "renders no medium weight body without a dismiss button" do
      render_inline(described_class.new("content")) { |alert| alert.with_icon }

      expect(page).not_to have_selector(".font-medium")
    end

    it "renders the dismiss button in the color" do
      render_inline(described_class.new("content", color: :red), &:with_dismiss_button)

      expect(page).to have_selector("button.bg-red-50")
    end
  end
end
