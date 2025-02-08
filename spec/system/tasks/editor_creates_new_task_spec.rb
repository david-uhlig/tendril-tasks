require "rails_helper"

RSpec.describe "Editor creates new task", type: :system, js: true do
  let(:editor) { create(:user, :editor) }

  before do
    login_as(editor)  # Logging in the user using Warden helpers
    create(:project)
    visit new_task_path
    page.driver.browser.manage.window.resize_to(800, 1600)  # Set the screen size
  end

  context "when visiting the new task resource" do
    it "shows the create task mask" do
      expect(page).to have_content("Aufgabe anlegen")
      expect(page).to have_selector("input")
      expect(page).to have_selector("trix-editor")
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
      fill_in_rich_textarea with: "Some lengthy description"
      click_on "Speichern"

      expect(page).to have_content("Some lengthy title")
      expect(page).to have_content("Task was successfully created.")
    end

    it "saves the task with `Speichern und Neu`" do
      select "Project title", from: "Thema"
      fill_in "Titel", with: "Some lengthy title"
      fill_in_rich_textarea "Beschreibung", with: "Some lengthy description"
      click_on "Speichern & Neu"

      expect(page).to have_content("Aufgabe anlegen")
      expect(page.has_select?("Thema", selected: "Project title")).to be_truthy
      expect(page).to have_content(editor.name)
    end
  end
end
