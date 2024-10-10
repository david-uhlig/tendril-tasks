# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new(src: "https://example.com/test.png")) { "content" }
    end

    it "renders no content" do
      expect(page).not_to have_content("content")
    end

    it "renders an avatar image" do
      expect(page).to have_selector("img[src='https://example.com/test.png']")
    end

    it "renders the default scheme classes" do
      expect(page).to have_selector("img.rounded-full")
    end

    it "renders the default size classes" do
      expect(page).to have_selector("img.w-10.h-10")
    end
  end

  context "with alt text" do
    it "renders the alt text" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        alt: "alt_text")
      )
      expect(page).to have_selector("img[alt='alt_text']")
    end
  end

  context "with scheme" do
    it "renders the scheme classes" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        scheme: :square)
      )
      expect(page).to have_selector("img.rounded")
    end
  end

  context "with size" do
    it "renders the size classes" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        size: :extra_small
      ))
      expect(page).to have_selector("img.w-6.h-6")
    end
  end

  context "with additional css classes" do
    it "renders the css classes" do
      render_inline(described_class.new(
      src: "https://example.com/test.png",
      classes: "my-custom-class and-one-more"
      ))
      expect(page).to have_selector("img.my-custom-class.and-one-more")
    end
  end
end
