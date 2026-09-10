require "rails_helper"

RSpec.describe "User withdraws application", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user)
    create(:task_application, user: user)
    visit task_path(Task.last)
  end

  context "when withdrawing" do
    before do
      click_on "Meldung zurückziehen"
    end

    it "shows the confirmation dialog" do
      expect(page).to have_content("Bist du sicher, dass du kein Interesse mehr an dieser Aufgabe hast?")
    end
  end

  context "when confirming the withdrawal" do
    before do
      click_on "Meldung zurückziehen"
      within("section#confirm-application-withdrawal-1") do
        click_on "Meldung zurückziehen"
      end
    end

    it "shows the application form" do
      within("#task-application") do
        expect(page).to have_content("Interessiert? Hier melden!")
        expect(page).to have_selector("textarea")
        expect(page).to have_button("Meldung absenden")
      end
    end

    it "displays the notification" do
      within("#notifications") do
        expect(page).to have_content("Deine Meldung")
        expect(page).to have_content("wurde zurückgezogen")
      end
    end
  end
end
