require "rails_helper"

RSpec.describe Gustwave::Dropdowns::MenuItems::Divider, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:context) do
      render_inline(described_class.new) { "content" }
    end

    it "renders div tag" do
      expect(rendered_content).to have_selector("div")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("div.my-1.h-px.bg-gray-100")
    end

    it "ignores block content" do
      expect(rendered_content).not_to have_content("content")
    end
  end

  context "with custom tag" do
    it "renders the custom tag" do
      render_inline(described_class.new(tag: :span)) { "content" }
      expect(rendered_content).to have_selector("span")
      expect(rendered_content).not_to have_selector("div")
    end
  end
end
