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

    it "renders the base and blue classes" do
      expect(page).to have_selector("div.p-4.text-sm.rounded-lg.text-blue-800.bg-blue-50.dark\\:text-blue-400")
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
      red: "text-red-800.bg-red-50.dark\\:text-red-400",
      green: "text-green-800.bg-green-50.dark\\:text-green-400",
      yellow: "text-yellow-800.bg-yellow-50.dark\\:text-yellow-300",
      dark: "text-gray-800.bg-gray-50.dark\\:text-gray-300"
    }.each do |color, classes|
      it "renders the #{color} classes" do
        render_inline(described_class.new("content", color:))

        expect(page).to have_selector("div.#{classes}")
      end
    end

    it "renders no color classes for :none" do
      render_inline(described_class.new("content", color: :none))

      expect(page).to have_selector("div[role='alert']")
      expect(page).not_to have_selector("div.p-4")
      expect(page).not_to have_selector("div[class*='bg-']")
    end

    it "raises for an unknown color" do
      expect { render_inline(described_class.new("content", color: :pink)) }
        .to raise_error(Gustwave::Options::UnknownValueError)
    end
  end

  describe "border" do
    it "renders a border in the color" do
      render_inline(described_class.new("content", color: :red, border: true))

      expect(page).to have_selector("div.border.border-red-300.dark\\:border-red-800")
    end

    it "renders a gray border for :dark" do
      render_inline(described_class.new("content", color: :dark, border: true))

      expect(page).to have_selector("div.border.border-gray-300.dark\\:border-gray-600")
    end
  end

  describe "accent" do
    it "renders a top border" do
      render_inline(described_class.new("content", accent: true))

      expect(page).to have_selector("div.border-t-4.border-blue-300.rounded-none.dark\\:border-blue-800")
      expect(page).not_to have_selector("div.rounded-lg")
    end

    it "wins over border" do
      render_inline(described_class.new("content", border: true, accent: true))

      expect(page).to have_selector("div.border-t-4.rounded-none")
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
      render_inline(described_class.new("content", title: "Title")) { |alert| alert.icon(label: "Info") }

      expect(page).to have_selector("div.flex.items-center[role='alert']")
      expect(page).to have_selector("div > svg.shrink-0.inline.w-4.h-4.me-3[aria-hidden='true']")
      expect(page).to have_selector("div > span.sr-only", text: "Info")
      expect(page).to have_selector("div > div > span.font-medium", text: "Title")
      expect(page).to have_selector("div > div", text: "content")
    end

    it "renders no label without one" do
      render_inline(described_class.new("content")) { |alert| alert.icon }

      expect(page).to have_selector("svg")
      expect(page).not_to have_selector("span.sr-only")
    end

    it "top-aligns the icon for align: :start" do
      render_inline(described_class.new("content", align: :start)) { |alert| alert.icon }

      expect(page).to have_selector("div.flex")
      expect(page).not_to have_selector("div.items-center")
      expect(page).to have_selector("svg.mt-\\[2px\\]")
    end
  end

  describe "dismiss button" do
    it "renders a button dismissing the alert by a generated id" do
      render_inline(described_class.new("content", color: :red), &:dismiss_button)

      id = page.find("div[role='alert']")[:id]
      expect(id).to start_with("alert-")
      expect(page).to have_selector("div.flex > button[aria-label='Dismiss'][data-dismiss-target='##{id}']")
      expect(page).to have_selector("button > span.sr-only", text: "Dismiss")
      expect(page).to have_selector("button > svg.w-6.h-6")
    end

    it "renders the body in medium weight" do
      render_inline(described_class.new("content"), &:dismiss_button)

      expect(page).to have_selector("div.flex > div.font-medium", text: "content")
    end

    it "renders no medium weight body without a dismiss button" do
      render_inline(described_class.new("content")) { |alert| alert.icon }

      expect(page).not_to have_selector(".font-medium")
    end

    it "renders the color's and part's classes" do
      render_inline(described_class.new("content", color: :red), &:dismiss_button)

      expect(page).to have_selector("button.bg-red-50.text-red-500.hover\\:bg-red-200.focus\\:ring-red-400")
      expect(page).to have_selector("button.ms-auto.-mx-1\\.5.h-8.w-8.p-1\\.5.rounded-lg.focus\\:ring-2")
      expect(page).not_to have_selector("button.bg-transparent")
      expect(page).not_to have_selector("button.rounded-xs")
    end

    it "reuses a given id" do
      render_inline(described_class.new("content", id: "my-alert"), &:dismiss_button)

      expect(page).to have_selector("div#my-alert")
      expect(page).to have_selector("button[data-dismiss-target='#my-alert']")
    end

    it "uses a custom label" do
      render_inline(described_class.new("content")) { |alert| alert.dismiss_button("Close alert") }

      expect(page).to have_selector("button[aria-label='Close alert'] > span.sr-only", text: "Close alert")
    end

    it "renders block content without sr-only markup" do
      render_inline(described_class.new("content")) { |alert| alert.dismiss_button { "Got it" } }

      expect(page).to have_selector("button", text: "Got it")
      expect(page).not_to have_selector("button span.sr-only")
    end

    it "localizes the default label" do
      I18n.with_locale(:de) { render_inline(described_class.new("content"), &:dismiss_button) }

      expect(page).to have_selector("button[aria-label='Schließen'] > span.sr-only", text: "Schließen")
    end
  end
end
