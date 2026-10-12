# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::Navigation::BrandLabel, type: :component do
  it "shows a divider and the label linking to the home page" do
    site = Site.create!(name: "Acme", navigation_label: "ACME")

    render_inline(described_class.new(site))

    expect(page).to have_css("span[aria-hidden='true']", text: "")
    expect(page).to have_link("ACME", href: "/")
  end

  it "shows nothing when the label is turned off" do
    site = Site.create!(name: "Acme", display_navigation_label: false)

    render_inline(described_class.new(site))

    expect(page.native.inner_html).to be_blank
  end
end
