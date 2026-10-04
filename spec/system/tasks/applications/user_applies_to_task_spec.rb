require "rails_helper"

RSpec.describe "User applies to task", type: :system, js: true do
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
        click_button "Meldung absenden"
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

    it "celebrates with fireworks", optional: true do
      # The controller sizes the canvas and dims the backdrop, then removes both once the animation ends
      expect(page).to have_selector("[data-controller='fireworks']:not(.opacity-0) canvas[width]", visible: :all)
      # Uncomment to test the fade out behavior. Too expensive to generally run this test.
      # expect(page).to have_no_selector("[data-controller='fireworks']", visible: :all, wait: 30)
    end

    it "shows a thank you modal toward the end of the fireworks", optional: true do
      expect(page).to have_selector("[data-fireworks-target='modal'].opacity-0", visible: :all)
      # 50 rockets launched 250ms apart, plus the backdrop fade in
      # Uncomment to test the fade out behavior. Too expensive to generally run this test.
      # within("[data-fireworks-target='modal']:not(.opacity-0)", visible: :all, wait: 20) do
      #  expect(page).to have_content("Danke für dein Engagement!")
      # end
    end
  end

  context "when applying without a comment" do
    before do
      within("#task-application") do
        click_button "Meldung absenden"
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
  end
end
