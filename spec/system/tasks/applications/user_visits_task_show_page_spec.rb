require "rails_helper"

RSpec.describe "User visits task show page", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "when they haven't applied" do
    before do
      create(:task, :published, :with_published_project)
      visit task_path(Task.last)
    end

    it "displays the application form" do
      within("#task-application") do
        expect(page).to have_content("Interessiert? Hier melden!")
        expect(page).to have_selector("textarea")
        expect(page).to have_button("Zählt auf mich!")
      end
    end
  end

  context "when they have already applied" do
    before do
      create(:task_application,
             user: user,
             comment: "Ein toller Kommentar ist das.")
      visit task_path(Task.last)
    end

    it "displays the edit form" do
      within("#task-application") do
        expect(page).to have_content("Vielen Dank für deine Meldung!")
        expect(page).to have_content("Ein toller Kommentar ist das.")
        expect(page).to have_selector("textarea")
        expect(page).to have_button("Meldung bearbeiten")
        expect(page).to have_button("Meldung zurückziehen")
      end
    end
  end

  context "when they have applied and the grace period has passed" do
    before do
      create(:task_application,
             user: user,
             comment: "Comment create before grace period",
             created_at: (TaskApplication::GRACE_PERIOD + 1.minute).ago
      )
      visit task_path(Task.last)
    end

    it "displays the withdraw form" do
      within("#task-application") do
        expect(page).to have_content("Vielen Dank für deine Meldung!")
        expect(page).to have_content("Comment create before grace period")
        expect(page).to have_selector("textarea[disabled]")
        expect(page).not_to have_button("Meldung bearbeiten")
        expect(page).to have_button("Meldung zurückziehen")
      end
    end
  end
end
