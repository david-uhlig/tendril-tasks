require "rails_helper"

RSpec.describe Gustwave::AvatarGroup, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("div.flex.-space-x-4")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end
end
