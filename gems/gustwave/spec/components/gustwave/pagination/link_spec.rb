require "rails_helper"

RSpec.describe Gustwave::Pagination::Link, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "a", href: "/tasks"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new("2", href: "/tasks?page=2"))
    end

    it "renders a link with the href" do
      expect(rendered_content).to have_link("2", href: "/tasks?page=2")
    end

    it "renders no aria-current" do
      expect(rendered_content).not_to have_selector("a[aria-current]")
    end
  end

  context "when active" do
    it "marks the link as the current page" do
      render_inline(described_class.new("3", href: "/tasks?page=3", active: true))

      expect(rendered_content).to have_selector("a[href='/tasks?page=3'][aria-current=page]", text: "3")
    end
  end

  context "with text and block content" do
    it "renders the text and not the block content" do
      render_inline(described_class.new("Text", href: "/")) { "Block" }

      expect(rendered_content).to have_link("Text", href: "/")
      expect(rendered_content).not_to have_text("Block")
    end
  end

  context "with block content and no text" do
    it "renders the block content" do
      render_inline(described_class.new(href: "/")) { "Block" }

      expect(rendered_content).to have_link("Block", href: "/")
    end
  end

  context "with HTML attributes" do
    it "passes the attributes through to the link" do
      render_inline(described_class.new("2", href: "/tasks?page=2", data: { turbo_frame: "tasks" }))

      expect(rendered_content).to have_selector("a[data-turbo-frame='tasks']", text: "2")
    end
  end
end
