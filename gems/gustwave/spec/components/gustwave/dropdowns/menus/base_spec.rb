require "rails_helper"

RSpec.describe Gustwave::Dropdowns::Menus::Base, type: :component do
  with_options selector: "div", id: "dropdown-text-and-block-content-example" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new(id: "dropdown-34gfs2")) { "content" }
    end

    it "renders div tag" do
      expect(rendered_content).to have_selector("div")
    end

    it "renders id attribute" do
      expect(rendered_content).to have_selector("div[id='dropdown-34gfs2']")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("div.z-10.bg-white.rounded-lg")
    end

    it "renders block content" do
      expect(rendered_content).to have_selector("div", text: "content")
    end
  end

  context "with text" do
    it "renders text" do
      render_inline(described_class.new("text", id: "dropdown"))
      expect(rendered_content).to have_selector("div", text: "text")
    end

    it "renders text over block content" do
      render_inline(described_class.new("text", id: "dropdown")) { "content" }
      expect(rendered_content).to have_selector("div", text: "text")
      expect(rendered_content).not_to have_selector("div", text: "content")
    end
  end

  context "with content_for argument" do
    it "renders menu content elsewhere" do
      render_inline(described_class.new(id: "dropdown", content_for: :menu_area))
      expect(rendered_content).to be_empty
    end
  end

  describe "Slots" do
    context "with header" do
      it "renders header" do
        render_inline(described_class.new(id: "dropdown")) do
          it.header { "header_content" }
        end
        expect(rendered_content).to have_selector("header", text: "header_content")
      end

      it "renders header styling" do
        render_inline(described_class.new(id: "dropdown")) do
          it.header { "header_content" }
        end
        expect(rendered_content).to have_selector("header.px-4.py-2.text-sm")
      end

      it "renders custom header tag" do
        render_inline(described_class.new(id: "dropdown")) do
          it.header(tag: :span) { "header_content" }
        end
        expect(rendered_content).to have_selector("span", text: "header_content")
      end
    end

    context "with footer" do
      it "renders footer" do
        render_inline(described_class.new(id: "dropdown")) do
          it.footer { "footer_content" }
        end
        expect(rendered_content).to have_selector("footer", text: "footer_content")
      end

      it "renders footer styling" do
        render_inline(described_class.new(id: "dropdown")) do
          it.footer { "header_content" }
        end
        expect(rendered_content).to have_selector("footer.px-4.py-2.text-sm")
      end

      it "renders custom footer tag" do
        render_inline(described_class.new(id: "dropdown")) do
          it.footer(tag: :span) { "footer_content" }
        end
        expect(rendered_content).to have_selector("span", text: "footer_content")
      end
    end
  end
end
