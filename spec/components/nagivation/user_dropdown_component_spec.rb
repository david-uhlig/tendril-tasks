# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navigation::UserDropdownComponent, type: :component do
  let(:avatar_img_src) do
    "https://example.com/avatar.png"
  end

  context "with default options" do
    before(:each) do
      @user = create(:user)
      render_inline(described_class.new(user: @user)) { "content" }
    end

    it "renders dropdown" do
      expect(page).to have_selector("div#userDropdown")
    end

    it "renders user's name" do
      expect(page).to have_text(@user.name)
    end

    it "renders no content" do
      expect(page).not_to have_text("content")
    end

    it "renders the user's avatar" do
      expect(page).to have_selector("img[src='#{@user.avatar_url}']")
      expect(page).to have_selector("img[alt='#{@user.name + " avatar"}']")
    end

    it "renders no links" do
      expect(page).not_to have_selector("ul")
    end

    it "renders logout link" do
      expect(page).to have_selector("a[href='/users/sign_out']")
      expect(page).to have_text("Abmelden")
      expect(page).to have_selector("a[data-turbo-method='delete']")
    end
  end

  context "with links" do
    before(:each) do
      @user = create(:user)
      component = described_class.new(user: @user)
      component.with_links([
         { name: "Example", href: "https://example.com" },
         { name: "Projekte", href: "/projects" }
      ])
      render_inline(component)
    end

    it "renders unordered list" do
      expect(page).to have_selector("ul")
    end

    it "renders external link" do
      expect(page).to have_selector("li>a[href='https://example.com']")
      expect(page).to have_text("Example")
    end

    it "renders internal link" do
      expect(page).to have_selector("li>a[href='/projects']")
      expect(page).to have_text("Projekte")
    end
  end

  context "with admin links" do
    before(:each) do
      @user = create(:user)
      component = described_class.new(user: @user)
      component.with_admin_links([
                             { name: "Admin Dashboard", href: "/admin" },
                             { name: "Up", href: "/up" }
                           ])
      render_inline(component)
    end

    it "renders unordered list" do
      expect(page).to have_selector("ul")
    end

    it "renders admin dashboard link" do
      expect(page).to have_selector("li>a[href='/admin']")
      expect(page).to have_text("Admin Dashboard")
    end

    it "renders up link" do
      expect(page).to have_selector("li>a[href='/up']")
      expect(page).to have_text("Up")
    end
  end
end
