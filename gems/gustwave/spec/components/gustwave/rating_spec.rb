require "rails_helper"

RSpec.describe Gustwave::Rating, type: :component do
  let(:solid_star_path) do
    File.read(Gustwave::Engine.root.join("app/assets/images/gustwave/icons/solid/star.svg")).match(/<path d="([^"]+)"/)[1]
  end

  describe "stars" do
    it "fills the whole part of the score" do
      render_inline(described_class.new(4.95))

      expect(rendered_content).to have_selector("div[role='img'] > svg.text-yellow-300", count: 4)
      expect(rendered_content).to have_selector("div[role='img'] > svg.text-gray-300", count: 1)
    end

    it "renders no filled stars for a score of 0" do
      render_inline(described_class.new(0))

      expect(rendered_content).to have_selector("svg.text-gray-300", count: 5)
      expect(rendered_content).not_to have_selector("svg.text-yellow-300")
    end

    it "fills every star at max" do
      render_inline(described_class.new(5))

      expect(rendered_content).to have_selector("svg.text-yellow-300", count: 5)
      expect(rendered_content).not_to have_selector("svg.text-gray-300")
    end

    it "clamps a score above max" do
      render_inline(described_class.new(7, max: 3))

      expect(rendered_content).to have_selector("svg.text-yellow-300", count: 3)
      expect(rendered_content).not_to have_selector("svg.text-gray-300")
    end

    it "renders max stars when given max" do
      render_inline(described_class.new(2, max: 10))

      expect(rendered_content).to have_selector("svg", count: 10)
      expect(rendered_content).to have_selector("svg.text-yellow-300", count: 2)
    end

    it "renders a single star for max: 1" do
      render_inline(described_class.new(0.5, max: 1))

      expect(rendered_content).to have_selector("svg", count: 1)
      expect(rendered_content).to have_selector("svg.text-gray-300", count: 1)
    end

    it "uses the solid star icon" do
      render_inline(described_class.new(1, max: 1))

      expect(rendered_content).to have_selector("svg[fill='currentColor'] path[d='#{solid_star_path}']")
      expect(rendered_content).not_to have_selector("svg[stroke]")
    end

    it "hides the icons from screen readers" do
      render_inline(described_class.new(3))

      expect(rendered_content).to have_selector("svg[aria-hidden='true']", count: 5)
    end

    it "raises for a max that isn't a positive Integer" do
      expect { described_class.new(1, max: 0) }.to raise_error(ArgumentError, /max/)
      expect { described_class.new(1, max: -2) }.to raise_error(ArgumentError, /max/)
      expect { described_class.new(1, max: 2.5) }.to raise_error(ArgumentError, /max/)
      expect { described_class.new(1, max: "5") }.to raise_error(ArgumentError, /max/)
    end
  end

  describe "size" do
    {
      sm: { filled: "size-4\\.5", stars: "gap-0\\.5" },
      md: { filled: "size-6\\.5", stars: "gap-1\\.5" },
      lg: { filled: "size-9", stars: "gap-2" }
    }.each do |size, expected|
      context "with size #{size}" do
        before { render_inline(described_class.new(4, size:)) }

        it "sizes the filled and empty stars" do
          expect(rendered_content).to have_selector("svg.text-yellow-300.#{expected[:filled]}", count: 4)
          expect(rendered_content).to have_selector("svg.text-gray-300.#{expected[:filled]}", count: 1)
        end

        it "spaces the stars" do
          expect(rendered_content).to have_selector("div[role='img'].#{expected[:stars]}")
        end

        it "drops the icon's own default size" do
          expect(rendered_content).not_to have_selector("svg.h-6.w-6")
        end
      end
    end

    it "defaults to sm" do
      render_inline(described_class.new(4))

      expect(rendered_content).to have_selector("svg.size-4\\.5", count: 5)
      expect(rendered_content).to have_selector("div[role='img'].gap-0\\.5")
    end
  end

  describe "colors" do
    it "colors the filled stars yellow and the empty stars gray" do
      render_inline(described_class.new(4))

      expect(rendered_content).to have_selector("svg.text-yellow-300", count: 4)
      expect(rendered_content).to have_selector("svg.text-gray-300.dark\\:text-gray-500", count: 1)
    end

    it "lets the caller change the empty star color" do
      render_inline(described_class.new(4, empty_star_options: { class: "text-gray-200 dark:text-gray-600" }))

      expect(rendered_content).to have_selector("svg.text-gray-200.dark\\:text-gray-600", count: 1)
      expect(rendered_content).not_to have_selector("svg.text-gray-300")
    end

    it "lets the caller change the filled star color, which wins over the default" do
      render_inline(described_class.new(4, filled_star_options: { class: "text-red-500" }))

      expect(rendered_content).to have_selector("svg.text-red-500", count: 4)
      expect(rendered_content).not_to have_selector("svg.text-yellow-300")
    end
  end

  describe "label" do
    it "announces the default label in English" do
      I18n.with_locale(:en) { render_inline(described_class.new(4.95)) }

      expect(rendered_content).to have_selector("div[role='img'][aria-label='Rated 4.95 out of 5']")
    end

    it "announces the default label in German" do
      I18n.with_locale(:de) { render_inline(described_class.new(4.95)) }

      expect(rendered_content).to have_selector("div[role='img'][aria-label='Bewertet mit 4.95 von 5']")
    end

    it "strips insignificant zeros from the value" do
      render_inline(described_class.new(4, max: 3))

      expect(rendered_content).to have_selector("div[role='img'][aria-label='Rated 4 out of 3']")
    end

    it "announces a custom label" do
      render_inline(described_class.new(4.95, max: 1, label: "Rated 4.95 out of 5"))

      expect(rendered_content).to have_selector("div[role='img'][aria-label='Rated 4.95 out of 5']")
    end
  end

  describe "content block" do
    it "renders no content by default" do
      render_inline(described_class.new(4))

      expect(rendered_content).to have_selector("div.flex.items-center > div[role='img']", count: 1)
      expect(rendered_content).not_to have_selector("div.flex.items-center > div[role='img'] ~ *")
    end

    it "renders the block after the stars" do
      render_inline(described_class.new(4.95)) { '<p class="score">4.95</p>'.html_safe }

      expect(rendered_content).to have_selector("div.flex.items-center > div[role='img'] + p.score", exact_text: "4.95")
    end

    it "keeps the block out of the stars' label" do
      render_inline(described_class.new(4)) { '<span>73 reviews</span>'.html_safe }

      expect(rendered_content).to have_selector("div[role='img'][aria-label='Rated 4 out of 5']")
      expect(rendered_content).not_to have_selector("div[role='img'] span")
    end
  end

  describe "options" do
    it "merges the stars options, with the caller's class winning" do
      render_inline(described_class.new(4, stars_options: { class: "gap-4", id: "row", data: { x: "1" } }))

      expect(rendered_content).to have_selector("div#row[role='img'].gap-4[data-x='1']")
      expect(rendered_content).not_to have_selector("div.gap-0\\.5")
      expect(rendered_content).to have_selector("div#row.flex.items-center")
    end

    it "merges the filled star options into each filled icon" do
      render_inline(described_class.new(4, filled_star_options: { data: { test: "star" } }))

      expect(rendered_content).to have_selector("svg[data-test='star']", count: 4)
    end

    it "renders HTML attributes on the root element" do
      render_inline(described_class.new(4, class: "mb-4", id: "rating"))

      expect(rendered_content).to have_selector("div#rating.flex.items-center.mb-4")
    end
  end
end
