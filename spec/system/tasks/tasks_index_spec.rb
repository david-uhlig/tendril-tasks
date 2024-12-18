require "rails_helper"

RSpec.describe "Tasks index", type: :system, js: true do
  context "when the user clicks the 'Mehr erfahren' button for a task" do
    let(:user) { create(:user) }
    let(:task) do
      create(:task,
             :published,
             :with_published_project,
             title: "Task Title 42")
    end

    before do
      login_as(user)
      # Create the task and visit the index page
      task
      visit tasks_path
    end

    it "navigates to the task detail page and shows the correct details" do
      expect(page).to have_selector("a", text: "Mehr erfahren")
      click_on "Mehr erfahren"
      # Verify the user is redirected to the task detail page
      expect(page).to have_current_path(task_path(task))
      # Verify the task title is displayed on the detail page
      expect(page).to have_selector("h2", text: task.title)
      # Verify specific content is displayed
      expect(page).to have_content("Interessiert? Hier melden!")
    end
  end
end
