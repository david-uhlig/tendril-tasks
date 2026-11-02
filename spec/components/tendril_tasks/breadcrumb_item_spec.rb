require "rails_helper"

RSpec.describe TendrilTasks::BreadcrumbItem, type: :component do
  it "renders the compact chevron as separator by default" do
    render_inline(described_class.new("Section", href: "/section"))

    expect(page).to have_selector("li svg.w-3.h-3.mx-1.text-gray-400 > path[d='m1 9 4-4-4-4']")
    expect(page).not_to have_selector("svg.w-6")
    expect(page).to have_link("Section", href: "/section")
  end

  it "renders the home icon" do
    render_inline(described_class.new("Home", href: "/", icon: :home))

    expect(page).to have_selector("li svg.me-2\\.5")
    expect(page).not_to have_selector("svg.mx-1")
  end

  it "renders no icon for none" do
    render_inline(described_class.new("Page", icon: :none))

    expect(page).not_to have_selector("svg")
    expect(page).to have_selector("li[aria-current='page']", text: "Page")
  end
end
