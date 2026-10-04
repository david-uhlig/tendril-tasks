require "rails_helper"

RSpec.describe "Delete confirmation cooldown", type: :system, js: true, optional: true do
  let(:user) { create(:user) }

  before do
    allow(AppConfig).to receive(:delete_confirm_cooldown).and_return(2)
    login_as(user, scope: :user)
    visit profile_path
    click_button "Mein Konto löschen"
  end

  it "disables the confirm button with a countdown when the modal opens" do
    within("#confirm-account-deletion") do
      expect(page).to have_button("Konto endgültig löschen (2)", disabled: true)
      expect(page).to have_button("Abbrechen", disabled: false)
    end
  end

  it "enables the confirm button after the cooldown" do
    within("#confirm-account-deletion") do
      click_button "Konto endgültig löschen", exact: true, wait: 4
    end

    expect(page).to have_current_path(root_path)
    expect(User.find_by(id: user.id)).to be_nil
  end

  it "restarts the cooldown when the modal is opened again" do
    within("#confirm-account-deletion") do
      expect(page).to have_button("Konto endgültig löschen", exact: true, disabled: false, wait: 4)
      click_button "Abbrechen"
    end

    click_button "Mein Konto löschen"

    within("#confirm-account-deletion") do
      expect(page).to have_button("Konto endgültig löschen (2)", disabled: true)
    end
  end
end
