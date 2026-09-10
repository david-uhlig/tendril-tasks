require "rails_helper"

RSpec.describe "User withdraws application after grace period and reapplies",
               type: :system,
               js: true do
  let(:user) { create(:user) }
  let(:task) { create(:task,
                      :published,
                      :with_published_project,
                      coordinators: [ user ])
  }
  let(:application) { create(:task_application,
                             :grace_period_expired,
                             task: task,
                             user: user)
  }

  before do
    login_as(user)
    visit task_path(application.task)
    click_on "Meldung zurückziehen"
    within("section#confirm-application-withdrawal-#{application.task.id}") do
      click_on "Meldung zurückziehen"
    end
  end

  context "when reapplying" do
    before do
      within("#task-application") do
        click_button "Meldung absenden"
      end
    end

    it "replaces the headline" do
      expect(page).to have_content("Vielen Dank für deine Meldung")
    end

    it "allows the user to scroll the page" do
      initial_scroll_position = page.evaluate_script("window.scrollY")
      page.scroll_to :bottom
      new_scroll_position = page.evaluate_script("window.scrollY")

      # Assert that the scroll position has changed
      expect(new_scroll_position).to be > initial_scroll_position
    end
  end
end
