require "rails_helper"

RSpec.describe "User applies to task", js: true do
  let(:user) { create(:user) }

  before do
    login_as(user)
    create(:task, :published, :with_published_project)
    visit task_path(Task.last)
  end

  context "when applying with a comment" do
    before do
      within("#task-application") do
        fill_in "task_application_comment", with: "My comment for the coordinators"
        click_button "Zählt auf mich!"
      end
    end

    it "replaces the headline" do
      expect(page).to have_content("Vielen Dank für deine Meldung!")
    end

    it "displays the edit form" do
      within("#task-application") do
        expect(page).to have_selector("textarea")
        expect(page).to have_content("My comment for the coordinators")
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

  context "when applying without a comment" do
    before do
      within("#task-application") do
        click_button "Zählt auf mich!"
      end
    end

    it "replaces the headline" do
      expect(page).to have_content("Vielen Dank für deine Meldung!")
    end

    it "displays the edit form" do
      within("#task-application") do
        expect(page).to have_selector("textarea")
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
