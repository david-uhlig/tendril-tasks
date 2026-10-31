require "rails_helper"

RSpec.describe "Gustwave modal dismissible", type: :system, js: true do
  def press_escape
    find(":focus").send_keys(:escape)
  end

  it "default closes with Escape" do
    visit "/rails/view_components/gustwave/modal/default"
    find("#default-modal-toggle").click
    expect(page).to have_css("#default-modal", visible: :visible)

    press_escape
    expect(page).to have_no_css("#default-modal", visible: :visible)
  end

  it "not_dismissible ignores Escape" do
    visit "/rails/view_components/gustwave/modal/not_dismissible"
    find("#not-dismissible-modal-toggle").click
    expect(page).to have_css("#not-dismissible-modal", visible: :visible)

    press_escape
    expect(page).to have_css("#not-dismissible-modal", visible: :visible)
  end

  it "not_dismissible ignores a backdrop click" do
    visit "/rails/view_components/gustwave/modal/not_dismissible"
    find("#not-dismissible-modal-toggle").click
    expect(page).to have_css("#not-dismissible-modal", visible: :visible)

    find("#not-dismissible-modal").click(x: 5, y: 5)
    expect(page).to have_css("#not-dismissible-modal", visible: :visible)
  end

  it "not_dismissible has no close button" do
    visit "/rails/view_components/gustwave/modal/not_dismissible"
    find("#not-dismissible-modal-toggle").click
    expect(page).to have_css("#not-dismissible-modal", visible: :visible)

    within("#not-dismissible-modal") do
      expect(page).to have_no_button("Close")
      expect(page).to have_no_button("Schließen")
    end
  end

  it "not_dismissible closes with its footer button" do
    visit "/rails/view_components/gustwave/modal/not_dismissible"
    find("#not-dismissible-modal-toggle").click
    expect(page).to have_css("#not-dismissible-modal", visible: :visible)

    within("#not-dismissible-modal") { click_button "Accept" }
    expect(page).to have_no_css("#not-dismissible-modal", visible: :visible)
  end

  it "Escape still closes the default modal after a not_dismissible one was shown" do
    visit "/rails/view_components/gustwave/modal/not_dismissible"
    find("#not-dismissible-modal-toggle").click
    within("#not-dismissible-modal") { click_button "Accept" }
    expect(page).to have_no_css("#not-dismissible-modal", visible: :visible)

    visit "/rails/view_components/gustwave/modal/default"
    find("#default-modal-toggle").click
    expect(page).to have_css("#default-modal", visible: :visible)

    press_escape
    expect(page).to have_no_css("#default-modal", visible: :visible)
  end
end
