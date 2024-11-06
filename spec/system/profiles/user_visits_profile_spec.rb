require "rails_helper"

RSpec.describe "User visits profile page", type: :system do
  context "when unauthorized" do
    it "redirects to login page" do
      visit profile_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("Log in")
    end
  end

  context "when authorized" do
    it "displays user profile page" do
      user = create(:user)
      login_as(user, scope: :user)

      visit profile_path
      expect(page).to have_content("Deine E-Mail-Adresse")
      expect(page).to have_content("Dein RCB Chat Benutzername")
    end
  end
end
