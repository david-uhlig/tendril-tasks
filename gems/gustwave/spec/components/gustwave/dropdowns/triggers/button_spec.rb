require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Triggers::Button, type: :component do
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

    it "renders button tag" do
      expect(rendered_content).to have_selector("button[type='button']")
    end

    it "renders the menu id as data attribute" do
      expect(rendered_content).to have_selector("button[data-dropdown-toggle='dropdown-menu']")
    end

    it "points aria-controls at the menu" do
      expect(rendered_content).to have_selector("button[aria-controls='dropdown-menu']")
    end

    it "renders a trailing chevron pointing down" do
      expect(rendered_content).to have_selector("button > svg > path[d='#{icon_path_data.call(:chevron_down)}']")
    end
  end

  context "with placement" do
    {
      top: :chevron_up,
      bottom: :chevron_down,
      left: :chevron_left,
      right: :chevron_right
    }.each do |placement, icon|
      it "renders the #{icon} chevron for the #{placement} placement" do
        render_inline(described_class.new(menu_id: "menu", placement:)) { "content" }

        expect(page).to have_selector("button > svg > path[d='#{icon_path_data.call(icon)}']")
      end
    end

    it "renders the top chevron for the top_start placement" do
      render_inline(described_class.new(menu_id: "menu", placement: :top_start)) { "content" }

      expect(page).to have_selector("button > svg > path[d='#{icon_path_data.call(:chevron_up)}']")
    end
  end

  context "with trailing icon false" do
    it "renders no trailing icon" do
      render_inline(described_class.new(menu_id: "menu", trailing_icon: false)) { "content" }

      expect(page).not_to have_selector("svg")
    end
  end

  context "with a custom trailing icon" do
    it "renders the custom icon instead of the chevron" do
      render_inline(described_class.new(menu_id: "menu", placement: :top, trailing_icon: :check))

      expect(page).to have_selector("button > svg", count: 1)
      expect(page).to have_selector("button > svg > path[d='#{icon_path_data.call(:check)}']")
    end
  end

  context "with theme" do
    it "renders the button of the theme" do
      render_inline(described_class.new(menu_id: "menu", theme: :outline)) { "content" }

      expect(page).to have_selector("button.border")
    end

    it "renders the default theme otherwise" do
      render_inline(described_class.new(menu_id: "menu")) { "content" }

      expect(page).not_to have_selector("button.border")
    end
  end

  context "with icon" do
    it "renders icon" do
      render_inline(described_class.new(menu_id: "dropdown-menu", icon: :check))

      expect(rendered_content).to have_selector("button > svg > path[d='#{icon_path_data.call(:check)}']")
    end
  end

  context "with trailing icon" do
    it "renders trailing icon" do
      render_inline(described_class.new(menu_id: "dropdown-menu", trailing_icon: :check))

      expect(rendered_content).to have_selector("button > svg > path[d='#{icon_path_data.call(:check)}']")
    end
  end

  context "delegates missing to Gustwave::Button" do
    it "delegates leading_icon to Gustwave::Button" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.with_leading_visual_icon(:check)
      end

      expect(rendered_content).to have_selector("button > svg > path[d='#{icon_path_data.call(:check)}']")
    end

    it "delegates leading_indicator to Gustwave::Button" do
      render_inline(described_class.new(menu_id: "dropdown-menu")) do
        it.with_leading_visual_indicator(color: :red)
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
  end
end
