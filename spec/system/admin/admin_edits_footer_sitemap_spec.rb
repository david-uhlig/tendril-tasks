require "rails_helper"

RSpec.describe "Admin edits footer sitemap", type: :system, js: true, optional: true do
  let(:admin) { create(:user, :admin) }
  let(:links) { "#sitemap-links-form .sitemap-link" }

  def first_category
    first("#sitemap-links-form .sitemap-category")
  end

  before do
    login_as(admin)
    visit edit_admin_footer_path
  end

  it "shows two empty categories with a link each" do
    expect(page).to have_css("#sitemap-links-form .sitemap-category", count: 2)
    expect(page).to have_css(links, count: 2)
  end

  it "adds a link to a category" do
    within(first_category) { click_button "Link" }

    expect(page).to have_css(links, count: 3)
    within(first_category) { expect(page).to have_css(".sitemap-link", count: 2) }
  end

  it "removes a link" do
    within(first_category) do
      find(".sitemap-link").click_button "Entfernen"
    end

    expect(page).to have_css(links, count: 1)
  end

  it "resets a category" do
    within(first_category) do
      fill_in "Kategorie", with: "About"
      click_button "Link"
    end
    within(first_category) { click_button "Zurücksetzen" }

    within(first_category) do
      expect(page).to have_field("Kategorie", with: "")
      expect(page).to have_css(".sitemap-link", count: 1)
    end
  end

  it "saves the categories and links" do
    within(first_category) do
      fill_in "Kategorie", with: "About"
      find("input[aria-label='Name des Links']").set("Homepage")
      find("input[aria-label='Adresse des Links']").set("https://example.com")
    end
    within("#sitemap-links-form") { click_button "Speichern" }

    expect(page).to have_content("Gespeichert")
    category = Footer::Sitemap.load.categories.sole
    expect(category.title).to eq("About")
    expect(category.links.map { [ it.title, it.href ] }).to eq([ [ "Homepage", "https://example.com/" ] ])
  end
end
