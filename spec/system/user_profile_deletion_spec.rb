require "rails_helper"

RSpec.describe 'User profile deletion', type: :system, js: true do
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

    # Click on the "Konto löschen" button inside the modal
    within('#delete-account-confirm') do
      click_button 'Konto löschen'
    end

    # Ensure the user is redirected to the root path after profile deletion
    expect(page).to have_current_path(root_path)

    # Optionally check for a flash message confirming account deletion
    # expect(page).to have_content('Your account has been successfully deleted.')
  end
end
