require "rails_helper"

RSpec.describe Gustwave::ModalFooter, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders the base classes" do
      expect(rendered_content).to have_selector("div.flex.items-center.gap-3.border-t.rounded-b")
    end

    it "renders block content" do
      expect(rendered_content).to have_selector("div", text: "content")
    end
  end

  context "with a caller class" do
    it "merges the caller class with the base classes" do
      render_inline(described_class.new(class: "p-2")) { "content" }
      expect(rendered_content).to have_selector("div.p-2.gap-3")
      expect(rendered_content).not_to have_selector("div.p-4")
    end
  end
end
