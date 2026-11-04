# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Banner, type: :component do
  # The constructor convention is checked for all components in
  # constructor_convention_spec.rb
  it_behaves_like "a text and block content renderer", selector: "div[tabindex='-1']"
  it_behaves_like "a component with configurable html attributes", selector: "div[tabindex='-1']"
  it_behaves_like "a component with a dismiss button slot", "content", id_prefix: "banner"

  context "with default options" do
    before(:each) { render_inline(described_class.new("content")) }

    it "renders a fixed bar at the top" do
      expect(page).to have_selector("div.fixed.top-0.w-full.border-b")
    end

    it "renders the root with tabindex -1" do
      expect(page).to have_selector("div[tabindex='-1']", text: "content")
    end

    it "renders no id" do
      expect(page).not_to have_selector("div[id]")
    end

    it "renders no role" do
      expect(page).not_to have_selector("div[role]")
    end

    it "renders the body centered with the text" do
      expect(page).to have_selector("div.flex-1.text-center", text: "content")
    end

    it "renders the body without flex" do
      expect(page).not_to have_selector("div.flex-1.flex")
    end
  end

  describe "position" do
    it "renders a bottom bar" do
      render_inline(described_class.new("content", position: :bottom))

      expect(page).to have_selector("div.bottom-0.border-t")
      expect(page).not_to have_selector("div[class~='top-0']")
    end

    it "renders no fixed positioning for :none" do
      render_inline(described_class.new("content", position: :none))

      expect(page).not_to have_selector("div.fixed")
    end
  end

  describe "floating" do
    it "renders a centered card at the top" do
      render_inline(described_class.new("content", floating: true))

      expect(page).to have_selector("div[class~='top-6'][class~='start-1/2'][class~='rounded-lg'][class~='shadow-xs'][class~='bg-white'][class~='border-gray-100']")
    end

    it "removes the full-width bar classes at the top" do
      render_inline(described_class.new("content", floating: true))

      expect(page).not_to have_selector("div[class~='top-0']")
      expect(page).not_to have_selector("div[class~='start-0']")
      expect(page).not_to have_selector("div[class~='border-b']")
      expect(page).not_to have_selector("div[class~='bg-gray-50']")
      expect(page).not_to have_selector("div[class~='border-gray-200']")
    end

    it "renders a centered card at the bottom" do
      render_inline(described_class.new("content", position: :bottom, floating: true))

      expect(page).to have_selector("div[class~='bottom-6']")
      expect(page).not_to have_selector("div[class~='bottom-0']")
      expect(page).not_to have_selector("div[class~='border-t']")
    end

    it "leaves the layout and the dismiss button alone" do
      render_inline(described_class.new("content", floating: true), &:with_dismiss_button)

      expect(page).not_to have_selector("div[class~='flex-col']")
      expect(page).not_to have_selector("button.absolute")
    end
  end

  describe "align" do
    it "aligns the body to the start" do
      render_inline(described_class.new("content", align: :start))

      expect(page).to have_selector("div.flex-1.text-start", text: "content")
      expect(page).not_to have_selector("div.text-center")
    end
  end

  describe "dismiss button" do
    it "has no padding that would squeeze its icon" do
      render_inline(described_class.new("content"), &:with_dismiss_button)

      expect(page).to have_selector("button.w-7.h-7.p-0")
    end

    it "follows the body as a direct child of the root" do
      render_inline(described_class.new("content"), &:with_dismiss_button)

      expect(page).to have_selector("div[tabindex='-1'] > div.flex-1 + button")
    end
  end
end
