require "rails_helper"

RSpec.describe Gustwave::Dropdowns::MenuItems::LinkButton, type: :component do
  icons_dir = File.expand_path("../../../../../app/assets/images/gustwave/icons/outline", __dir__)

  # The path data of an outline icon's source file, to match the rendered <path>
  icon_path_data = ->(name) { File.read(File.join(icons_dir, "#{name.to_s.dasherize}.svg"))[/ d="([^"]+)"/, 1] }

  with_options selector: "a" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new)
    end

    it "renders anchor tag" do
      expect(rendered_content).to have_selector("a[href='#']")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("a.flex.items-center.w-full")
    end
  end

  context "with icon argument" do
    before(:context) do
      render_inline(described_class.new(icon: :check))
    end

    it "renders icon" do
      expect(rendered_content).to have_selector("a > svg > path[d='#{icon_path_data.call(:check)}']")
    end

    it "renders icon styling" do
      expect(rendered_content).to have_selector('a > svg:first-child.h-\[1\.5em\]')
    end
  end

  context "with trailing icon argument" do
    before(:context) do
      render_inline(described_class.new(trailing_icon: :check))
    end

    it "renders icon" do
      expect(rendered_content).to have_selector("a > svg > path[d='#{icon_path_data.call(:check)}']")
    end

    it "renders icon styling" do
      expect(rendered_content).to have_selector('a > svg:last-child.h-\[1\.5em\].ms-auto')
    end
  end

  context "with Gustwave::Button slots" do
    it "renders a leading visual icon before the text" do
      link = described_class.new("Go")
      link.with_leading_visual_icon(:check)
      render_inline(link)

      expect(page).to have_xpath("//a/svg[following-sibling::text()[normalize-space()='Go']]")
    end

    it "renders a trailing visual icon after the text" do
      link = described_class.new("Go")
      link.with_trailing_visual_icon(:check)
      render_inline(link)

      expect(page).to have_xpath("//a/svg[preceding-sibling::text()[normalize-space()='Go']]")
    end
  end
end
