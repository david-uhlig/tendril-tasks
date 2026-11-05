require "rails_helper"

RSpec.describe Gustwave::Progress, type: :component do
  with_options selector: "div[role='progressbar']" do
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:each) { render_inline(described_class.new(45)) }

    it "renders the track as a progressbar" do
      expect(rendered_content).to have_selector("div[role='progressbar']")
    end

    it "reports the value and range to screen readers" do
      expect(rendered_content).to have_selector("div[role='progressbar'][aria-valuenow='45'][aria-valuemin='0'][aria-valuemax='100']")
    end

    it "renders the base track styling" do
      expect(rendered_content).to have_selector("div.w-full.bg-gray-200.rounded-full.h-2\\.5.dark\\:bg-gray-700")
    end

    it "fills the bar to the value" do
      expect(rendered_content).to have_selector("div[role='progressbar'] > div.bg-blue-600.h-2\\.5.rounded-full[style='width: 45%']")
    end

    it "renders no label" do
      expect(rendered_content).not_to have_content("%")
    end
  end

  context "without a value" do
    it "starts at zero" do
      render_inline(described_class.new)

      expect(rendered_content).to have_selector("div[aria-valuenow='0'] > div[style='width: 0%']")
    end
  end

  context "with a value outside 0 to 100" do
    it "clamps a value above 100" do
      render_inline(described_class.new(140))

      expect(rendered_content).to have_selector("div[aria-valuenow='100'] > div[style='width: 100%']")
    end

    it "clamps a value below 0" do
      render_inline(described_class.new(-5))

      expect(rendered_content).to have_selector("div[aria-valuenow='0'] > div[style='width: 0%']")
    end
  end

  context "with size argument" do
    it "renders the size on the track and bar" do
      render_inline(described_class.new(45, size: :lg))

      expect(rendered_content).to have_selector("div.h-4[role='progressbar'] > div.h-4")
    end

    it "renders the smallest size" do
      render_inline(described_class.new(45, size: :sm))

      expect(rendered_content).to have_selector("div.h-1\\.5[role='progressbar'] > div.h-1\\.5")
    end

    it "renders the extra large size" do
      render_inline(described_class.new(45, size: :xl))

      expect(rendered_content).to have_selector("div.h-6[role='progressbar'] > div.h-6")
    end

    it "applies no height to the inside label" do
      render_inline(described_class.new(45, size: :lg, label: :inside))

      expect(rendered_content).not_to have_selector("div.h-4")
    end
  end

  context "with color argument" do
    it "renders the color on the bar" do
      render_inline(described_class.new(45, color: :red))

      expect(rendered_content).to have_selector("div[role='progressbar'] > div.bg-red-600.dark\\:bg-red-500")
    end

    it "renders the dark color" do
      render_inline(described_class.new(45, color: :dark))

      expect(rendered_content).to have_selector("div > div.bg-gray-600.dark\\:bg-gray-300")
    end

    it "doesn't color the track" do
      render_inline(described_class.new(45, color: :green))

      expect(rendered_content).not_to have_selector("div.bg-green-600[role='progressbar']")
    end
  end

  context "with label inside" do
    before(:each) { render_inline(described_class.new(45, label: :inside)) }

    it "shows the percentage in the bar" do
      expect(rendered_content).to have_selector("div[role='progressbar'] > div", exact_text: "45%")
    end

    it "styles the bar for the label" do
      expect(rendered_content).to have_selector("div > div.text-xs.text-center.p-0\\.5.leading-none")
    end

    it "doesn't render a label row" do
      expect(rendered_content).not_to have_selector("span")
    end
  end

  context "with label outside" do
    it "renders the block content as the title and the percentage in a row above the track" do
      render_inline(described_class.new(45, label: :outside)) { "Flowbite" }

      expect(rendered_content).to have_selector("div.flex.justify-between.mb-1 > span.text-base", exact_text: "Flowbite")
      expect(rendered_content).to have_selector("div.flex.justify-between.mb-1 > span.text-sm", exact_text: "45%")
    end

    it "renders the track after the row" do
      render_inline(described_class.new(45, label: :outside)) { "Flowbite" }

      expect(rendered_content).to have_selector("div > div.flex + div[role='progressbar']")
    end

    it "labels the track with the title" do
      render_inline(described_class.new(45, label: :outside)) { "Flowbite" }

      title_id = Capybara.string(rendered_content).find("span.text-base")[:id]
      expect(title_id).to be_present
      expect(rendered_content).to have_selector("div[role='progressbar'][aria-labelledby='#{title_id}']")
    end

    it "renders only the percentage without block content" do
      render_inline(described_class.new(45, label: :outside))

      expect(rendered_content).to have_selector("span.text-sm", exact_text: "45%")
      expect(rendered_content).not_to have_selector("span.text-base")
      expect(rendered_content).not_to have_selector("div[role='progressbar'][aria-labelledby]")
    end

    it "keeps the track's attributes off the wrapper" do
      render_inline(described_class.new(45, label: :outside, id: "upload", class: "mb-4")) { "Flowbite" }

      expect(rendered_content).to have_selector("div[role='progressbar'][id='upload'].mb-4")
      expect(rendered_content).not_to have_selector("div[id='upload'] > .flex")
    end
  end

  context "with bar_options" do
    it "passes the attributes on to the bar" do
      render_inline(described_class.new(45, bar_options: { data: { test: "bar" } }))

      expect(rendered_content).to have_selector("div[role='progressbar'] > div[data-test='bar']")
    end

    it "lets the caller's classes win conflicts on the bar" do
      render_inline(described_class.new(45, bar_options: { class: "bg-orange-500" }))

      expect(rendered_content).to have_selector("div > div.bg-orange-500")
      expect(rendered_content).not_to have_selector("div > div.bg-blue-600")
    end
  end

  context "with aria options" do
    it "passes an accessible label through to the track" do
      render_inline(described_class.new(45, aria: { label: "Upload" }))

      expect(rendered_content).to have_selector("div[role='progressbar'][aria-label='Upload']")
    end
  end
end
