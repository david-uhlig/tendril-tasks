require "rails_helper"

RSpec.describe Gustwave::TableCaption, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "caption"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("caption.p-5.text-lg.font-semibold")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with custom HTML attributes" do
    it "adds attributes to the HTML tag" do
      render_inline(described_class.new(id: "caption1234", class: "bg-white")) { "content" }
      expect(rendered_content).to have_selector("caption[id='caption1234'].p-5.text-lg.font-semibold.bg-white")
    end
  end

  context "with title slot content" do
    it "renders the content" do
      render_inline(described_class.new) do |component|
        component.title { "title_content" }
      end
      expect(rendered_content).to have_selector("caption", text: "title_content")
    end
  end

  context "with description slot content" do
    it "renders the content" do
      render_inline(described_class.new) do |component|
        component.description { "description_content" }
      end
      expect(rendered_content).to have_selector("p.mt-1.text-sm.font-normal", text: "description_content")
    end
  end
end
