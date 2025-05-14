require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Triggers::InlineButton, type: :component do
  with_options selector: "button", menu_id: "dropdown-menu" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu")) { "content" }
    end

    it "renders default styles" do
      expect(rendered_content).to have_selector("button.align-baseline.gap-0")
    end

    it "renders button tag" do
      expect(rendered_content).to have_selector("button[type='button']")
    end

    it "renders the menu id as data attribute" do
      expect(rendered_content).to have_selector("button[data-dropdown-toggle='dropdown-menu']")
    end

    it "renders a trailing icon" do
      expect(rendered_content).to have_selector("button>svg")
    end
  end

  context "with icon" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu", icon: :check))
    end

    it "renders icon" do
      expect(rendered_content).to have_selector('button>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end

    it "applies icon styles" do
      expect(rendered_content).to have_selector('button>svg.h-\[1\.5em\].w-auto')
    end
  end

  context "with trailing icon" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu", trailing_icon: :check))
    end

    it "renders trailing icon" do
      expect(rendered_content).to have_selector('button>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end

    it "applies icon styles" do
      expect(rendered_content).to have_selector('button>svg.h-\[1\.5em\].w-auto')
    end
  end

  context "delegates missing to Gustwave::Buttons::Base" do
    it "delegates leading_icon to Gustwave::Buttons::Base" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.leading_icon(:check)
      end
      expect(rendered_content).to have_selector('button>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end

    it "delegates leading_indicator to Gustwave::Button" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.leading_indicator(scheme: :red)
      end
      expect(rendered_content).to have_selector('button>span.rounded-full.bg-red-500[aria-hidden="true"]')
    end
  end
end
