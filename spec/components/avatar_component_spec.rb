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

  context "with options" do
    it "renders alt text" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        options: {
          alt: "alt_text"
        }
      ))
      expect(page).to have_selector("img[alt='alt_text']")
    end

    it "prefers alt parameter over alt options" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        alt: "prefers_this",
        options: {
          alt: "alt_text"
        }
      ))
      expect(page).to have_selector("img[alt='prefers_this']")
      expect(page).not_to have_selector("img[alt='alt_text']")
    end

    it "renders css classes" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        options: {
          class: "my-custom-class and-some-other-class"
        }
      ))
      expect(page).to have_selector("img.my-custom-class.and-some-other-class")
    end

    it "renders classes parameter and class options" do
      render_inline(described_class.new(
        src: "https://example.com/test.png",
        classes: "class-from-here and-one-more",
        options: {
          class: "my-custom-class and-some-other-class"
        }
      ))
      expect(page).to have_selector("img.class-from-here.and-one-more")
      expect(page).to have_selector("img.my-custom-class.and-some-other-class")
    end

    context "containing HTML attributes" do
      it "renders data attributes" do
        render_inline(described_class.new(
          src: "https://example.com/test.png",
          options: {
            data: { "dropdown-toggle": "userDropdown" }
          }
        ))
        expect(page).to have_selector("img[data-dropdown-toggle='userDropdown']")
      end

      it "renders id" do
        render_inline(described_class.new(
          src: "https://example.com/test.png",
          options: {
            id: "avatarButton"
          }
        ))
        expect(page).to have_selector("img[id='avatarButton']")
      end

      it "renders type" do
        render_inline(described_class.new(
          src: "https://example.com/test.png",
          options: {
            type: "button"
          }
        ))
        expect(page).to have_selector("img[type='button']")
      end
    end
  end
end
