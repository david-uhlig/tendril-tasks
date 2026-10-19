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

    it "renders id attribute" do
      expect(rendered_content).to have_selector("div[id='dropdown-34gfs2']")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("div.rounded-lg")
    end

    it "renders no header or footer" do
      expect(rendered_content).not_to have_selector("header, footer")
    end
  end

  context "with tag argument" do
    it "renders a nav tag" do
      render_inline(described_class.new(id: "dropdown", tag: :nav)) { "content" }

      expect(rendered_content).to have_selector("nav#dropdown", text: "content")
    end

    it "renders a section tag" do
      render_inline(described_class.new(id: "dropdown", tag: :section)) { "content" }

      expect(rendered_content).to have_selector("section#dropdown", text: "content")
    end
  end

  context "with content_for argument" do
    it "renders the menu in the content area instead of inline" do
      host = stub_const("MenuAreaHost", Class.new(Gustwave::Component) {
        def call
          safe_join([
            render(Gustwave::Dropdowns::Menus::Base.new(id: "dropdown", content_for: :menu_area)) { "menu_content" },
            tag.div(content_for(:menu_area), id: "menu-area")
          ])
        end
      })

      render_inline(host.new)

      expect(page).to have_selector("#menu-area > div#dropdown", text: "menu_content")
      expect(page).to have_selector("div#dropdown", count: 1)
    end
  end

  describe "Slots" do
    context "with header" do
      it "renders header" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_header { "header_content" }
        end
        expect(rendered_content).to have_selector("header", text: "header_content")
      end

      it "renders custom header tag" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_header(tag: :span) { "header_content" }
        end
        expect(rendered_content).to have_selector("span", text: "header_content")
      end
    end

    context "with footer" do
      it "renders footer" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_footer { "footer_content" }
        end
        expect(rendered_content).to have_selector("footer", text: "footer_content")
      end

      it "renders custom footer tag" do
        render_inline(described_class.new(id: "dropdown")) do
          it.with_footer(tag: :span) { "footer_content" }
        end
        expect(rendered_content).to have_selector("span", text: "footer_content")
      end
    end
  end
end
