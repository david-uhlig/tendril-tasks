# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::Avatar, type: :component do
  let(:user) { create(:user, :with_avatar) }

  context "with default options" do
    before(:each) do
      render_inline(described_class.new(user)) { "content" }
    end

    it "renders no content" do
      expect(page).not_to have_content("content")
    end

    it "renders the avatar stored by the app" do
      expect(page).to have_selector("img[src='#{Rails.application.routes.url_helpers.rails_storage_proxy_path(user.avatar, only_path: true)}']")
    end

    it "doesn't render the avatar URL" do
      expect(page).not_to have_selector("img[src='#{user.avatar_url}']")
    end

    it "renders the default shape classes" do
      expect(page).to have_selector("img.rounded-full")
    end

    it "renders the default size classes" do
      expect(page).to have_selector("img.w-10.h-10")
    end
  end

  context "without a stored avatar" do
    before(:each) do
      render_inline(described_class.new(build_stubbed(:user), size: :xs, class: "custom"))
    end

    it "renders a placeholder" do
      expect(page).not_to have_selector("img")
      expect(page).to have_selector("div.w-6.h-6.rounded-full.custom svg")
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

  context "with shape" do
    it "renders the shape classes" do
      render_inline(described_class.new(
        user,
        shape: :square)
      )
      expect(page).to have_selector("img.rounded-sm")
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
