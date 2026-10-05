require "rails_helper"

RSpec.describe "User withdraws application", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user)
    create(:task_application, user: user)
    visit task_path(Task.last)
  end

  context "when confirming the withdrawal" do
    it "shows the confirmation dialog, then the application form and a notification", :aggregate_failures do
      click_on "Meldung zurückziehen"
      expect(page).to have_content("Bist du sicher, dass du kein Interesse mehr an dieser Aufgabe hast?")

      within("section#confirm-application-withdrawal-1") do
        click_on "Meldung zurückziehen"
      end

      within("#task-application") do
        expect(page).to have_content("Interessiert? Hier melden!")
        expect(page).to have_selector("textarea")
        expect(page).to have_button("Meldung absenden")
      end

      within("#notifications") do
        expect(page).to have_content("Deine Meldung")
        expect(page).to have_content("wurde zurückgezogen")
      end
    end
  end
end
