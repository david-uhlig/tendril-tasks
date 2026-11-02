require "rails_helper"

RSpec.describe Gustwave::Pagination, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "nav"

  # The path data of each chevron icon's single shape
  let(:left_chevron_path) { "m14 8-4 4 4 4" }
  let(:right_chevron_path) { "m10 16 4-4-4-4" }

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) do |pagination|
        pagination.with_page("1", href: "/tasks?page=1")
        pagination.with_page("2", href: "/tasks?page=2")
      end
    end

    it "renders the links in a nav, ul and li structure" do
      expect(rendered_content).to have_selector("nav > ul > li > a[href='/tasks?page=1']", text: "1")
      expect(rendered_content).to have_selector("nav > ul > li > a[href='/tasks?page=2']", text: "2")
    end

    it "labels the navigation landmark" do
      expect(rendered_content).to have_selector("nav[aria-label='Page navigation']")
    end

    it "renders the links at the small size" do
      expect(rendered_content).to have_selector("a.h-8", count: 2)
      expect(rendered_content).to have_selector("ul.text-sm")
    end
  end

  context "with custom aria label" do
    it "replaces the default label" do
      render_inline(described_class.new(aria: { label: "Tasks" })) { |pagination| pagination.with_page("1", href: "/") }

      expect(rendered_content).to have_selector("nav[aria-label='Tasks']")
      expect(rendered_content).not_to have_selector("nav[aria-label='Page navigation']")
    end
  end

  context "with slots set in a different order" do
    it "renders previous, pages and next in that order" do
      render_inline(described_class.new) do |pagination|
        pagination.with_next_page("Forward", href: "/3")
        pagination.with_page("1", href: "/1")
        pagination.with_page("2", href: "/2")
        pagination.with_previous_page("Back", href: "/0")
      end

      expect(page.all("a").map(&:text)).to eq(%w[Back 1 2 Forward])
    end
  end

  context "with rounded links" do
    it "rounds the first and last links and leaves the middle link square" do
      render_inline(described_class.new) do |pagination|
        pagination.with_previous_page(href: "/0")
        pagination.with_page("1", href: "/1")
        pagination.with_page("2", href: "/2")
        pagination.with_page("3", href: "/3")
        pagination.with_next_page(href: "/4")
      end

      expect(page).to have_selector("a[href='/0'].rounded-s-lg")
      expect(page).to have_selector("a[href='/4'].rounded-e-lg")
      expect(page.find("a[href='/0']")[:class]).not_to include("rounded-e-lg")
      expect(page.find("a[href='/4']")[:class]).not_to include("rounded-s-lg")

      middle = page.find("a[href='/2']")[:class]
      expect(middle).not_to include("rounded-s-lg", "rounded-e-lg", "rounded-lg")
    end

    it "rounds a single link on all corners" do
      render_inline(described_class.new) { |pagination| pagination.with_page("1", href: "/1") }

      expect(page).to have_selector("a[href='/1'].rounded-lg")
    end

    it "rounds the first page link at the start without a previous page" do
      render_inline(described_class.new) do |pagination|
        pagination.with_page("1", href: "/1")
        pagination.with_page("2", href: "/2")
        pagination.with_next_page(href: "/3")
      end

      expect(page).to have_selector("a[href='/1'].rounded-s-lg")
    end

    it "rounds the last page link at the end without a next page" do
      render_inline(described_class.new) do |pagination|
        pagination.with_previous_page(href: "/1")
        pagination.with_page("1", href: "/2")
        pagination.with_page("2", href: "/3")
      end

      expect(page).to have_selector("a[href='/3'].rounded-e-lg")
    end
  end

  context "with default labels" do
    it "labels the arrows in English" do
      render_inline(described_class.new) do |pagination|
        pagination.with_previous_page(href: "/1")
        pagination.with_next_page(href: "/3")
      end

      expect(page).to have_link("Previous", href: "/1")
      expect(page).to have_link("Next", href: "/3")
    end

    it "labels the arrows in German" do
      I18n.with_locale(:de) do
        render_inline(described_class.new) do |pagination|
          pagination.with_previous_page(href: "/1")
          pagination.with_next_page(href: "/3")
        end
      end

      expect(page).to have_link("Zurück", href: "/1")
      expect(page).to have_link("Weiter", href: "/3")
    end

    it "labels the navigation in German" do
      I18n.with_locale(:de) do
        render_inline(described_class.new) { |pagination| pagination.with_page("1", href: "/1") }
      end

      expect(rendered_content).to have_selector("nav[aria-label='Seitennavigation']")
    end
  end

  context "with custom text" do
    it "replaces the default label" do
      render_inline(described_class.new) { |pagination| pagination.with_previous_page("Back", href: "/") }

      expect(page).to have_link("Back", href: "/")
      expect(page).not_to have_link("Previous")
    end
  end

  context "with size md" do
    it "renders the links and the list at the medium size" do
      render_inline(described_class.new(size: :md)) do |pagination|
        pagination.with_page("1", href: "/1")
        pagination.with_page("2", href: "/2")
      end

      expect(rendered_content).to have_selector("a.h-10", count: 2)
      expect(rendered_content).to have_selector("ul.text-base")
    end
  end

  context "with icon only arrows" do
    before(:each) do
      render_inline(described_class.new) do |pagination|
        pagination.with_previous_page(href: "/1", icon_only: true)
        pagination.with_page("1", href: "/2")
        pagination.with_next_page(href: "/3", icon_only: true)
      end
    end

    it "renders an icon in each arrow" do
      expect(page).to have_selector("a[href='/1'] svg")
      expect(page).to have_selector("a[href='/3'] svg")
    end

    it "keeps the label for screen readers only" do
      expect(page).to have_selector("a[href='/1'] span.sr-only", text: "Previous", visible: :all)
      expect(page).to have_selector("a[href='/3'] span.sr-only", text: "Next", visible: :all)
    end

    it "renders the left chevron for previous and the right chevron for next" do
      expect(page.find("a[href='/1'] svg path")[:d]).to eq(left_chevron_path)
      expect(page.find("a[href='/3'] svg path")[:d]).to eq(right_chevron_path)
    end

    it "does not render an icon in a page link" do
      expect(page).not_to have_selector("a[href='/2'] svg")
    end
  end

  context "with block content in a page" do
    it "renders the block content" do
      render_inline(described_class.new) do |pagination|
        pagination.with_page(href: "/") { "Block" }
      end

      expect(page).to have_link("Block", href: "/")
    end
  end

  context "with html attributes" do
    it "passes data attributes through to the nav" do
      render_inline(described_class.new(data: { turbo_frame: "tasks" })) do |pagination|
        pagination.with_page("1", href: "/1")
      end

      expect(rendered_content).to have_selector("nav[data-turbo-frame='tasks']")
    end
  end
end
