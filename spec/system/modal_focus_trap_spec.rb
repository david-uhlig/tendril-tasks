require "rails_helper"

RSpec.describe "Modal focus trap", type: :system, js: true do
  let(:user) { create(:user) }
  let(:modal) { "#confirm-account-deletion" }

  def focused
    find(":focus")
  end

  before do
    allow(AppConfig).to receive(:delete_confirm_cooldown).and_return(0)
    login_as(user, scope: :user)
    visit profile_path
  end

  it "keeps focus within the modal and returns it to the toggle on close", :aggregate_failures do
    click_button "Mein Konto löschen"

    # Moves focus into the modal when it opens
    expect(page).to have_selector("#{modal} button[data-modal-hide]:focus", text: "Schließen")

    # Wraps Tab from the last element to the first
    focused.send_keys(:tab, :tab)
    expect(page).to have_selector("#{modal} button:focus", text: "Konto endgültig löschen")
    focused.send_keys(:tab)
    expect(page).to have_selector("#{modal} button:focus", text: "Schließen")

    # Wraps Shift+Tab from the first element to the last
    focused.send_keys([ :shift, :tab ])
    expect(page).to have_selector("#{modal} button:focus", text: "Konto endgültig löschen")

    # Returns focus to the toggle when the modal closes
    within(modal) { click_button "Abbrechen" }
    expect(page).to have_no_selector(modal, visible: true)
    expect(page).to have_selector("button:focus", text: "Mein Konto löschen")
  end
end
