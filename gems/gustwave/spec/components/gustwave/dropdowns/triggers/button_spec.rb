require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Triggers::Button, type: :component do
  with_options selector: "button", menu_id: "dropdown-menu" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu")) { "content" }
    end

    it "renders button tag" do
      expect(rendered_content).to have_selector("button[type='button']")
    end

    it "renders the menu id as data attribute" do
      expect(rendered_content).to have_selector("button[data-dropdown-toggle='dropdown-menu']")
    end

    it "points aria-controls at the menu" do
      expect(rendered_content).to have_selector("button[aria-controls='dropdown-menu']")
    end

    it "renders a trailing icon" do
      expect(rendered_content).to have_selector("button>svg")
    end
  end

  it "points the trailing icon to an underscored placement" do
    top = render_inline(described_class.new(menu_id: "menu", placement: :top)).css("svg").to_html
    top_start = render_inline(described_class.new(menu_id: "menu", placement: :top_start)).css("svg").to_html

    expect(top_start).to be_present
    expect(top_start).to eq(top)
  end

  context "with data attributes" do
    it "keeps the menu id next to the caller's data" do
      render_inline(described_class.new(menu_id: "menu", data: { controller: "x" })) { "content" }

      expect(page).to have_selector("button[data-controller='x'][data-dropdown-toggle='menu']")
    end

    it "does not let the caller's data override the menu id" do
      render_inline(described_class.new(menu_id: "menu", data: { "dropdown-toggle": "other" })) { "content" }

      expect(page).to have_selector("button[data-dropdown-toggle='menu']")
      expect(page).not_to have_selector("button[data-dropdown-toggle='other']")
    end
  end

  context "with icon" do
    it "renders icon" do
      render_inline(described_class.new(menu_id: "dropdown-menu", icon: :check))
      expect(rendered_content).to have_selector('button>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end
  end

  context "with trailing icon" do
    it "renders trailing icon" do
      render_inline(described_class.new(menu_id: "dropdown-menu", trailing_icon: :check))
      expect(rendered_content).to have_selector('button>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end
  end

  context "delegates missing to Gustwave::Button" do
    it "delegates leading_icon to Gustwave::Button" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.leading_icon(:check)
      end
      expect(rendered_content).to have_selector('button>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end

    it "delegates leading_indicator to Gustwave::Button" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.leading_indicator(color: :red)
      end
      expect(rendered_content).to have_selector('button>span.rounded-full.bg-red-500[aria-hidden="true"]')
    end
  end

  context "with a placement and trigger event" do
    it "omits Flowbite's defaults" do
      render_inline(described_class.new(menu_id: "menu")) { "content" }

      expect(page).not_to have_selector("button[data-dropdown-trigger], button[data-dropdown-placement]")
    end

    it "renders them otherwise, converting underscores in the placement" do
      render_inline(described_class.new(menu_id: "menu", placement: :top_start, trigger_event: :hover)) { "content" }

      expect(page).to have_selector("button[data-dropdown-placement='top-start'][data-dropdown-trigger='hover']")
    end

    it "raises for an unknown placement or trigger event" do
      expect { described_class.new(menu_id: "menu", placement: :above) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :above for :placement/)
      expect { described_class.new(menu_id: "menu", trigger_event: :tap) }
        .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :tap for :trigger_event/)
    end
  end
end
