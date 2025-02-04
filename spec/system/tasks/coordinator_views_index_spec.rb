require "rails_helper"

RSpec.describe "Coordinator views index page", type: :system do
  let!(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "visibility" do
    context "unpublished task" do
      it "is not shown" do
        create(:task,
               :not_published,
               coordinators: [ user ],
               title: "Unpublished Task")
        visit tasks_path
        expect(page).not_to have_content("Unpublished Task")
      end
    end

    context "published task with unpublished project" do
      it "is not shown" do
        create(:task,
               :published,
               :with_unpublished_project,
               coordinators: [ user ],
               title: "Published Task with unpublished project")
        visit tasks_path
        expect(page).not_to have_content("Published Task with unpublished project")
      end
    end
  end
end
