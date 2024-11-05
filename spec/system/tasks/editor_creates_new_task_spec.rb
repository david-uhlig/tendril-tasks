require "rails_helper"

RSpec.describe "Editor creates new task", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    # TODO change scope to editor once its implemented
    login_as(user, scope: :user)  # Logging in the user using Warden helpers
    create(:project)
    visit new_task_path
  end

  context "when visiting the new task resource" do
    it "shows the create task mask" do
      expect(page).to have_content("Aufgabe erstellen")
      expect(page).to have_selector("input")
      expect(page).to have_selector("textarea")
      expect(page).to have_selector("button", count: 3)
    end
  end

  context "when saving the task without values" do
    it "shows validation errors" do
      click_on "Speichern"
      expect(page).to have_selector("span[id^='error-message-for-']", count: 3)
    end
  end

  context "when saving the task with valid values" do
    it "saves the task with `Speichern`" do
      select "Project title", from: "task_form_project_id"
      fill_in "Titel", with: "Some lengthy title"
      fill_in "Beschreibung", with: "Some lengthy description"
      click_on "Speichern"

      expect(page).to have_content("Task was successfully created.")
    end

    it "saves the task with `Speichern und Neu`" do
      select "Project title", from: "Projekt"
      fill_in "Titel", with: "Some lengthy title"
      fill_in "Beschreibung", with: "Some lengthy description"
      click_on "Speichern & Neu"

      expect(page).to have_content("Aufgabe erstellen")
      expect(page.has_select?("Projekt", selected: "Project title")).to be_truthy
      expect(page).to have_content(user.name)
    end
  end
end
