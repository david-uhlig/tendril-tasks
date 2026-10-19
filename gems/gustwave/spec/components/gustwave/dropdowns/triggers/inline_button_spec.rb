require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Triggers::InlineButton, type: :component do
  icons_dir = File.expand_path("../../../../../app/assets/images/gustwave/icons/outline", __dir__)

  # The path data of an outline icon's source file, to match the rendered <path>
  icon_path_data = ->(name) { File.read(File.join(icons_dir, "#{name.to_s.dasherize}.svg"))[/ d="([^"]+)"/, 1] }

  with_options selector: "button", menu_id: "dropdown-menu" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  it_behaves_like "a dropdown trigger owning its attributes"

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu")) { "content" }
    end

    it "renders default styles" do
      expect(rendered_content).to have_selector("button.align-baseline.gap-0")
    end

    it "renders no button styling" do
      expect(rendered_content).not_to have_selector("button.rounded-lg")
    end

    it "renders button tag" do
      expect(rendered_content).to have_selector("button[type='button']")
    end

    it "renders the menu id as data attribute" do
      expect(rendered_content).to have_selector("button[data-dropdown-toggle='dropdown-menu']")
    end

    it "renders a trailing chevron pointing down" do
      expect(rendered_content).to have_selector("button > svg:last-child > path[d='#{icon_path_data.call(:chevron_down)}']")
    end
  end

  context "with icon" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu", icon: :check))
    end

    it "renders icon" do
      expect(rendered_content).to have_selector("button > svg:first-child > path[d='#{icon_path_data.call(:check)}']")
    end

    it "applies icon styles" do
      expect(rendered_content).to have_selector('button > svg:first-child.h-\[1\.5em\].w-auto')
    end
  end

  context "with trailing icon" do
    before(:context) do
      render_inline(described_class.new(menu_id: "dropdown-menu", trailing_icon: :check))
    end

    it "renders trailing icon" do
      expect(rendered_content).to have_selector("button > svg:last-child > path[d='#{icon_path_data.call(:check)}']")
    end

    it "applies icon styles" do
      expect(rendered_content).to have_selector('button > svg:last-child.h-\[1\.5em\].w-auto')
    end
  end

  context "delegates missing to Gustwave::Buttons::Base" do
    it "delegates leading_icon to Gustwave::Buttons::Base" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.with_leading_visual_icon(:check)
      end

      expect(rendered_content).to have_selector("button > svg:first-child > path[d='#{icon_path_data.call(:check)}']")
    end

    it "delegates leading_indicator to Gustwave::Button" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.with_leading_visual_indicator(color: :red)
      end

      expect(rendered_content).to have_selector('button>span.rounded-full.bg-red-500[aria-hidden="true"]')
    end
  end
end
