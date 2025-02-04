require "rails_helper"

RSpec.describe "User views index page", type: :system do
  let!(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "task visibility" do
    context "unpublished task" do
      it "is not shown" do
        create(:task, :not_published, title: "Unpublished Task")
        visit tasks_path
        expect(page).not_to have_content("Unpublished Task")
      end
    end

    context "published task with unpublished project" do
      it "is not shown" do
        create(:task,
               :published,
               :with_unpublished_project,
               title: "Published Task with unpublished project")
        visit tasks_path
        expect(page).not_to have_content("Published Task with unpublished project")
      end
    end

    context "published task with published project" do
      it "is shown" do
        create(:task,
               :published,
               :with_published_project,
               title: "Published Task with published project")
        visit tasks_path
        expect(page).to have_content("Published Task with published project")
      end
    end
  end

  context "project filter options" do
    context "published project with published tasks" do
      it "is shown" do
        create(:project,
               :published,
               :with_published_tasks,
               title: "Published Project with published tasks")
        visit tasks_path

        within("#filter-by-project") do
          expect(page).to have_content("Published Project with published tasks")
        end
      end
    end

    context "published project with unpublished tasks" do
      it "is not shown" do
        create(:project,
               :published,
               :with_unpublished_tasks,
               title: "Published Project with unpublished tasks")
        visit tasks_path

        expect(page).not_to have_content("Published Project with unpublished tasks")
      end
    end

    context "unpublished project" do
      it "is not shown" do
        create(:project, :not_published, title: "Unpublished Project")
        visit tasks_path

        expect(page).not_to have_content("Unpublished Project")
      end
    end
  end

  it "does not show the new task button" do
    visit tasks_path
    expect(page).not_to have_link("Aufgabe anlegen")
  end
end
