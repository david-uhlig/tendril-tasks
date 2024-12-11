require "rails_helper"

RSpec.describe "User visits profile page", type: :system do
  context "when unauthorized" do
    it "redirects to the login page" do
      visit profile_path
      expect(page).to have_content("Willkommen zurück")
      expect(page).to have_content("Anmelden mit RCB Chat")
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
