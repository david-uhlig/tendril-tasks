require "rails_helper"

RSpec.describe 'User aborts profile deletion', type: :system, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)  # Logging in the user using Warden helpers
    visit profile_path
  end

  it 'allows the user to delete their profile after confirming' do
    click_button 'Mein Konto löschen'

    # Ensure the confirmation modal appears with the expected text
    expect(page).to have_content('Konto löschen?')
    expect(page).to have_content("Bist du sicher, dass du dein Konto endgültig löschen möchtest?")

    # Click on the "Abbrechen" button inside the modal
    within('#delete-account-confirm') do
      click_button 'Abbrechen'
    end

    expect(page).not_to have_content('Konto löschen?')

    expect(page).to have_current_path(profile_path)
  end
end
