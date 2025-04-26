require "rails_helper"

RSpec.describe Gustwave::TableHead, type: :component do
  context "with default options" do
    before(:each) do
      render_inline(described_class.new) { "content" }
    end

    it "renders default styling" do
      expect(rendered_content).to have_selector("thead")
    end

    it "renders block content" do
      expect(rendered_content).to have_content("content")
    end
  end

  context "with custom HTML attributes" do
    it "adds attributes to the HTML tag" do
      render_inline(described_class.new(id: "body1234", class: "bg-white")) { "content" }
      expect(rendered_content).to have_selector("thead[id='body1234'].bg-white")
    end
  end

  context "with col slot content" do
    it "renders a th tag within a tr tag when using the col slot alias" do
      render_inline(described_class.new) do |component|
        component.col { "col_content" }
      end
      expect(rendered_content).to have_selector("tr")
      expect(rendered_content).to have_selector("th", text: "col_content")
    end

    it "renders a th tag within a tr tag when using the th slot alias" do
      render_inline(described_class.new) do |component|
        component.th { "col_content" }
      end
      expect(rendered_content).to have_selector("tr")
      expect(rendered_content).to have_selector("th", text: "col_content")
    end
  end

  context "with col slot and block content" do
    it "appends block content after the th slot content" do
      render_inline(described_class.new) do |component|
        component.col { "col_content" }
        "<tr><th>block_content</th></tr>".html_safe
      end
      expect(rendered_content).to have_selector("tr", count: 2)
      expect(rendered_content).to have_selector("th", text: "col_content")
      expect(rendered_content).to have_selector("th", text: "block_content")
      expect(rendered_content).to match(/col_content.*block_content/)
    end
  end
end
