# frozen_string_literal: true

require "rails_helper"

# Test the specific modifications of this wrapper component.
# General `AvatarComponent` tests are carried out in that component.
RSpec.describe Navigation::UserDropdown::AvatarComponent, type: :component do
  let(:user) { build_stubbed(:user) }

  context "with default values" do
    before(:each) do
      render_inline(described_class.new(user))
    end

    it "renders id attribute" do
      expect(page).to have_selector("img[id='avatarButton']")
    end

    it "renders type attribute" do
      expect(page).to have_selector("img[type='button']")
    end

    it "renders data attributes" do
      expect(page).to have_selector("img[data-dropdown-toggle='userDropdown']")
      expect(page).to have_selector("img[data-dropdown-placement='bottom-start']")
    end
  end

  context "with options" do
    before(:each) do
      options = {
        id: "willGetIgnored",
        type: "willAlsoGetIgnored",
        width: "96%",
        tabindex: "34",
        data: { turbo: false }
      }
      render_inline(described_class.new(user, **options))
    end

    it "ignores id attribute from options" do
      expect(page).to have_selector("img[id='avatarButton']")
    end

    it "ignores type attribute from options" do
      expect(page).to have_selector("img[type='button']")
    end

    it "renders data attributes" do
      expect(page).to have_selector("img[data-turbo='false']")
    end

    it "renders additional html attributes" do
      expect(page).to have_selector("img[width='96%']")
      expect(page).to have_selector("img[tabindex='34']")
    end
  end
end
