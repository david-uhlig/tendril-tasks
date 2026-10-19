require "rails_helper"

RSpec.describe TendrilTasks::Navigation::AvatarDropdownMenu, type: :component do
  let(:user) do
    create(:user, :with_avatar)
  end

  context "as a visitor" do
    it "renders nothing" do
      render_inline(described_class.new)

      expect(rendered_content).to be_blank
    end
  end

  shared_context "rendered for a signed-in user" do
    before(:each) do
      as(user)
      render_inline(described_class.new)
    end
  end

  shared_examples "a signed-in user's menu" do
    it "renders the user's avatar" do
      expect(rendered_content).to have_selector("img[src='#{Rails.application.routes.url_helpers.rails_storage_proxy_path(user.avatar, only_path: true)}']")
    end

    it "renders the toggle trigger" do
      expect(rendered_content).to have_selector("div[data-dropdown-toggle='avatar-dropdown-menu']")
    end

    it "renders the menu" do
      expect(rendered_content).to have_selector("div#avatar-dropdown-menu")
    end

    it "renders the user's name" do
      expect(rendered_content).to have_selector("#avatar-dropdown-menu", text: user.name)
    end

    it "renders the profile and dashboard links" do
      expect(rendered_content).to have_selector("a[href='/profile']")
      expect(rendered_content).to have_selector("a[href='/dashboard']")
    end

    it "renders the logout link as a DELETE request" do
      expect(rendered_content).to have_selector("a[href='/users/sign-out'][data-turbo-method='delete']")
    end
  end

  context "as a user" do
    let(:user) { create(:user, :with_avatar) }

    include_context "rendered for a signed-in user"
    it_behaves_like "a signed-in user's menu"

    it "doesn't render the admin link" do
      expect(rendered_content).not_to have_selector("a[href='/admin']")
    end
  end

  context "as an editor" do
    let(:user) { create(:user, :editor, :with_avatar) }

    include_context "rendered for a signed-in user"
    it_behaves_like "a signed-in user's menu"

    it "renders the editor role badge" do
      expect(rendered_content).to have_selector("a[href]", text: "Redaktion")
    end

    it "doesn't render the admin link" do
      expect(rendered_content).not_to have_selector("a[href='/admin']")
    end
  end

  context "as an admin" do
    let(:user) { create(:user, :admin, :with_avatar) }

    include_context "rendered for a signed-in user"
    it_behaves_like "a signed-in user's menu"

    it "renders the admin role badge" do
      expect(rendered_content).to have_selector("a[href]", text: "Admin")
    end

    it "renders the admin link" do
      expect(rendered_content).to have_selector("a[href='/admin']")
    end
  end
end
