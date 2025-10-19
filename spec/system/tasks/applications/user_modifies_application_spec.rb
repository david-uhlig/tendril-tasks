require "rails_helper"

RSpec.describe "User edits application", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user)
    create(:task_application, user: user, comment: "Ein toller Kommentar ist das.")
    visit task_path(Task.last)
  end

  context "when editing" do
    before do
      within("#task-application") do
        fill_in "task_application_comment", with: "My edited comment"
        click_button "Meldung bearbeiten"
      end
    end

    it "displays the edited comment" do
      within("#task-application") do
        expect(page).to have_selector("textarea")
        expect(page).to have_content("My edited comment")
        expect(page).to have_button("Meldung bearbeiten")
        expect(page).to have_button("Meldung zurückziehen")
      end
    end

    it "displays notification" do
      within("#notifications") do
        expect(page).to have_content("Vielen Dank!")
      end
    end
  end
end
