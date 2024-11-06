require "rails_helper"

RSpec.describe "User deletes their profile", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)  # Logging in the user using Warden helpers
    visit profile_path
  end

  it "shows a confirmation dialog" do
    click_button "Mein Konto löschen"
    # Ensure the confirmation modal appears with the expected text
    expect(page).to have_content('Konto löschen?')
    expect(page).to have_content("Bist du sicher, dass du dein Konto endgültig löschen möchtest?")
  end

  context "when the user confirms the profile deletion" do
    it "redirects them to the page root" do
      click_button "Mein Konto löschen"

      # Click on the "Konto löschen" button inside the modal
      within('#confirm-account-deletion') do
        click_button 'Konto löschen'
      end

      # Ensure the user is redirected to the root path after profile deletion
      expect(page).to have_current_path(root_path)
      expect(page).to have_button("Anmelden")
    end
  end

  context "when the user aborts the profile deletion" do
    it "closes the confirmation dialog" do
      click_button "Mein Konto löschen"

      # Click on the "Konto löschen" button inside the modal
      within('#confirm-account-deletion') do
        click_button "Abbrechen"
      end

      # Dialog header should disappear
      expect(page).not_to have_content("Konto löschen?")
      expect(page).to have_current_path(profile_path)
    end
  end
end
