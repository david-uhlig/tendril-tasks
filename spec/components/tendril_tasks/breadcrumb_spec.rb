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
end
