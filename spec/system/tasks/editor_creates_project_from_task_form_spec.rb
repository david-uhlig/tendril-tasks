require "rails_helper"

RSpec.describe "Editor creates an initiative from the task form", type: :system, js: true do
  let(:editor) { create(:user, :editor) }

  before do
    login_as(editor)
    visit new_task_path
    page.driver.browser.manage.window.resize_to(800, 1600)
  end

  it "keeps the task's entries and selects the new initiative", :aggregate_failures do
    fill_in "Titel", with: "Some task title"
    fill_in_rich_textarea with: "Some task description"

    click_button "new-project-button"

    expect(page).to have_selector("#dimmed-backdrop")

    within "#new-project-modal" do
      expect(page).to have_content("Ein Thema bündelt zusammengehörige Aufgaben")
      expect(page).to have_checked_field("project_form_publish", visible: :all)

      fill_in "Titel", with: "Brand new initiative"
      fill_in_rich_textarea with: "Some initiative description"
      click_button "Speichern"
    end

    expect(page).to have_no_selector("#new-project-modal", visible: true)
    expect(page).to have_no_selector("#dimmed-backdrop")
    expect(page).to have_select("task_form_project_id", selected: "Brand new initiative")
    expect(page).to have_field("Titel", with: "Some task title")

    click_on "Speichern"

    expect(page).to have_content("Aufgabe wurde erfolgreich erstellt.")
    task = Task.last
    expect(task.title).to eq("Some task title")
    expect(task.description.to_plain_text).to include("Some task description")
    expect(task.project.title).to eq("Brand new initiative")
    expect(task.project.coordinators).to contain_exactly(editor)
  end

  it "keeps the modal open and shows the errors when invalid" do
    click_button "new-project-button"

    within "#new-project-modal" do
      click_button "Speichern"

      expect(page).to have_selector("#project_form_title")
      expect(page).to have_content("Bitte gib einen Titel an.")
    end
  end
end
