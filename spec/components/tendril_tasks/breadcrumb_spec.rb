require "rails_helper"

RSpec.describe TendrilTasks::Breadcrumb, type: :component do
  def home_link
    page.find("nav li a")
  end

  context "with the English locale" do
    it "renders the English home title by default" do
      I18n.with_locale(:en) do
        render_inline(described_class.new) { |breadcrumb| breadcrumb.with_home }

        expect(home_link).to have_text("Home")
      end
    end
  end

  context "with the German locale" do
    it "renders the German home title by default" do
      I18n.with_locale(:de) do
        render_inline(described_class.new) { |breadcrumb| breadcrumb.with_home }

        expect(home_link).to have_text("Start")
      end
    end
  end

  it "renders the given home title instead of the default" do
    render_inline(described_class.new) { |breadcrumb| breadcrumb.with_home "Dashboard", href: "/dashboard" }

    expect(home_link).to have_text("Dashboard")
  end

  it "marks only the last item as the current page when a middle item has no link" do
    render_inline(described_class.new) do |breadcrumb|
      breadcrumb.with_home
      breadcrumb.with_item "Imprint"
      breadcrumb.with_item "Edit"
    end

    expect(page).to have_selector("li[aria-current='page']", count: 1)
    expect(page).to have_selector("li[aria-current='page']", text: "Edit")
  end

  it "renders the home link before the items" do
    render_inline(described_class.new) do |breadcrumb|
      breadcrumb.with_home "Home", href: "/"
      breadcrumb.with_item "Section"
    end

    expect(page).to have_selector("li:first-child a[href='/'] svg")
    expect(page).to have_selector("li:last-child", text: "Section")
  end

  it "keeps long titles on one line" do
    render_inline(described_class.new(list_options: { class: "mb-3" })) { |breadcrumb| breadcrumb.with_home }

    expect(page).to have_selector("nav > ol.truncate.mb-3")
  end

  it "passes HTML attributes to the nav element" do
    render_inline(described_class.new(class: "mb-4")) { |breadcrumb| breadcrumb.with_home }

    expect(page).to have_selector("nav.mb-4")
  end

  it "renders the block of an item" do
    render_inline(described_class.new) do |breadcrumb|
      breadcrumb.with_home
      breadcrumb.with_item { "Block content" }
    end

    expect(page).to have_selector("li[aria-current='page']", text: "Block content")
  end
end
