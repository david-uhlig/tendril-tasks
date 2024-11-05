require "rails_helper"

RSpec.describe "Editor creates new task", type: :system, js: true do
  let(:user) { create(:user) }

  before do
    # TODO change scope to editor once its implemented
    login_as(user, scope: :user)  # Logging in the user using Warden helpers
    visit new_task_path
  end

  it "shows the create task mask" do
    expect(page).to have_content("Aufgabe erstellen")
    expect(page).to have_selector("input")
    expect(page).to have_selector("textarea")
    expect(page).to have_selector("button", count: 3)
  end
end
