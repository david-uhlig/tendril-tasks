require "rails_helper"

RSpec.describe "User views profile", type: :system do
  let(:user) { create(:user) }

  before do
    login_as(user, scope: :user)
    visit profile_path
  end

  it "declares the page language" do
    expect(page).to have_selector("html[lang='#{I18n.locale}']", visible: :all)
  end

  it "shows the email address and username as read-only values" do
    expect(page).to have_field("email", with: user.email, readonly: true)
    expect(page).to have_field("username", with: user.username, readonly: true)
  end
end
