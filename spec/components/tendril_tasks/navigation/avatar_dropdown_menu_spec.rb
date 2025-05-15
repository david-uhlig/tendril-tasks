require "rails_helper"

RSpec.describe TendrilTasks::Navigation::AvatarDropdownMenu, type: :component do
  let(:avatar_img_src) do
    "https://loremflickr.com/cache/resized/defaultImage.small_50_50_nofilter.jpg"
  end

  let(:user) do
    build_stubbed(:user)
  end

  context "as a visitor" do
    before(:each) do
      render_inline(described_class.new)
    end

    it "doesn't render the user's avatar" do
      expect(rendered_content).not_to have_selector("img[src]")
    end

    it "doesn't render the menu" do
      expect(rendered_content).not_to have_selector("div#avatar-dropdown-menu")
    end
  end

  context "as a logged in user" do
    before(:each) do
      as(user)
      render_inline(described_class.new)
    end

    it "renders the user's avatar" do
      expect(rendered_content).to have_selector("img[src='#{user.avatar_url}']")
    end

    it "renders the toggle trigger" do
      expect(rendered_content).to have_selector("div[data-dropdown-toggle='avatar-dropdown-menu']")
    end

    it "renders the menu" do
      expect(rendered_content).to have_selector("div#avatar-dropdown-menu")
    end

    it "renders user role links" do
      expect(rendered_content).to have_selector("a[href='/profile']")
      expect(rendered_content).to have_selector("a[href='/dashboard']")
    end

    it "doesn't render the admin link" do
      expect(rendered_content).not_to have_selector("a[href='/admin']")
    end

    it "renders the logout link" do
      expect(rendered_content).to have_selector("a[href='/users/sign_out']")
    end
  end

  context "as an editor" do
    before(:each) do
      user = build_stubbed(:user, :editor)
      as(user)
      render_inline(described_class.new)
    end

    it "renders the user's avatar" do
      expect(rendered_content).to have_selector("img[src='#{user.avatar_url}']")
    end

    it "renders the toggle trigger" do
      expect(rendered_content).to have_selector("div[data-dropdown-toggle='avatar-dropdown-menu']")
    end

    it "renders the menu" do
      expect(rendered_content).to have_selector("div#avatar-dropdown-menu")
    end

    it "renders user role links" do
      expect(rendered_content).to have_selector("a[href='/profile']")
      expect(rendered_content).to have_selector("a[href='/dashboard']")
    end

    it "doesn't render the admin link" do
      expect(rendered_content).not_to have_selector("a[href='/admin']")
    end

    it "renders the logout link" do
      expect(rendered_content).to have_selector("a[href='/users/sign_out']")
    end
  end

  context "as an admin" do
    before(:each) do
      user = build_stubbed(:user, :admin)
      as(user)
      render_inline(described_class.new)
    end

    it "renders the user's avatar" do
      expect(rendered_content).to have_selector("img[src='#{user.avatar_url}']")
    end

    it "renders the toggle trigger" do
      expect(rendered_content).to have_selector("div[data-dropdown-toggle='avatar-dropdown-menu']")
    end

    it "renders the menu" do
      expect(rendered_content).to have_selector("div#avatar-dropdown-menu")
    end

    it "renders user role links" do
      expect(rendered_content).to have_selector("a[href='/profile']")
      expect(rendered_content).to have_selector("a[href='/dashboard']")
    end

    it "renders the admin link" do
      expect(rendered_content).to have_selector("a[href='/admin']")
    end

    it "renders the logout link" do
      expect(rendered_content).to have_selector("a[href='/users/sign_out']")
    end
  end
end
