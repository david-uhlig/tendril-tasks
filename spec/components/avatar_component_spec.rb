# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::Avatar, type: :component do
  let(:user) { build_stubbed(:user) }

  context "with default options" do
    before(:each) do
      user = build_stubbed(:user, avatar_url: "https://loremflickr.com/300/300")
      render_inline(described_class.new(user)) { "content" }
    end

    it "renders no content" do
      expect(page).not_to have_content("content")
    end

    it "renders an avatar image" do
      expect(page).to have_selector("img[src='https://loremflickr.com/300/300']")
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
        user,
        alt: "alt_text")
      )
      expect(page).to have_selector("img[alt='alt_text']")
    end
  end

  context "with scheme" do
    it "renders the scheme classes" do
      render_inline(described_class.new(
        user,
        scheme: :square)
      )
      expect(page).to have_selector("img.rounded")
    end
  end

  context "with size" do
    it "renders the size classes" do
      render_inline(described_class.new(
        user,
        size: :xs
      ))
      expect(page).to have_selector("img.w-6.h-6")
    end
  end

  context "with additional css classes" do
    it "renders the css classes" do
      render_inline(described_class.new(
        user,
        class: "my-custom-class and-one-more"
      ))
      expect(page).to have_selector("img.my-custom-class.and-one-more")
    end
  end

  context "with options" do
    it "renders alt text" do
      render_inline(described_class.new(
        user,
        alt: "alt_text"
      ))
      expect(page).to have_selector("img[alt='alt_text']")
    end

    it "renders css classes" do
      render_inline(described_class.new(
        user,
        class: "my-custom-class and-some-other-class"
      ))
      expect(page).to have_selector("img.my-custom-class.and-some-other-class")
    end

    context "containing HTML attributes" do
      it "renders data attributes" do
        render_inline(described_class.new(
          user,
          data: { "dropdown-toggle": "userDropdown" }
        ))
        expect(page).to have_selector("img[data-dropdown-toggle='userDropdown']")
      end

      it "renders id" do
        render_inline(described_class.new(
          user,
          id: "avatarButton"
        ))
        expect(page).to have_selector("img[id='avatarButton']")
      end

      it "renders type" do
        render_inline(described_class.new(
          user,
          type: "button"
        ))
        expect(page).to have_selector("img[type='button']")
      end
    end
  end
end
