require "rails_helper"

RSpec.describe "Coordinator views index page", type: :system do
  let!(:user) { create(:user) }

  before do
    login_as(user)
  end

  context "visibility" do
    context "unpublished project" do
      it "is not shown" do
        create(:project,
               :not_published,
               coordinators: [ user ],
               title: "Unpublished Project")
        visit projects_path
        expect(page).not_to have_content("Unpublished Project")
      end
    end

    context "published project with unpublished tasks" do
      it "is not shown" do
        create(:project,
               :published,
               :with_unpublished_tasks,
               coordinators: [ user ],
               title: "Published Project with unpublished tasks")
        visit projects_path
        expect(page).not_to have_content("Published Project with unpublished tasks")
      end
    end
  end
end
