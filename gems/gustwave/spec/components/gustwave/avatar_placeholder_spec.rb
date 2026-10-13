# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::AvatarPlaceholder, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new)
    end

    it "renders the base styling" do
      expect(rendered_content).to have_css("div.relative.overflow-hidden.bg-gray-100")
    end

    it "renders the default placeholder SVG" do
      expect(rendered_content).to have_css("svg")
      expect(rendered_content).to include("M10 9a3 3 0 100-6 3 3 0 000 6z")
    end
  end

  context "with custom placeholder" do
    it "renders the image when src is provided" do
      render_inline(described_class.new(src: "https://example.com/avatar.png"))

      expect(rendered_content).to have_css("img[src='https://example.com/avatar.png']")
    end

    it "renders the block content when provided" do
      render_inline(described_class.new) do
        "<div class='custom-placeholder'>Custom Placeholder</div>".html_safe
      end

      expect(rendered_content).to have_css("div.custom-placeholder", text: "Custom Placeholder")
      expect(rendered_content).not_to include("<svg")
    end
  end
end
