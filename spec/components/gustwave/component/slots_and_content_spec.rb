require "rails_helper"

class SlotsAndContentComponent < Gustwave::Component
  renders_one :title, ->(text) { "<h1>#{text}</h1>".html_safe }
  renders_many :sections, ->(text) { "<p>#{text}</p>".html_safe }

  def call
    slots_and_content(title, sections)
  end
end

class SlotsAndContentComponentCustomContentPosition < Gustwave::Component
  renders_one :title, ->(text) { "<h1>#{text}</h1>".html_safe }
  renders_many :sections, ->(text) { "<p>#{text}</p>".html_safe }

  def call
    slots_and_content(title, content, sections, append_content: false)
  end
end

RSpec.describe Gustwave::Component, type: :component do
  describe "#slots_and_content" do
    let(:component) { SlotsAndContentComponent.new }
    let(:component_custom_content_position) { SlotsAndContentComponentCustomContentPosition.new }

    context "without slots and without content" do
      it "renders nothing" do
        render_inline(component)
        expect(rendered_content).to be_empty
      end
    end

    context "without slots" do
      it "renders content" do
        render_inline(component) do
          "<div>content</div>".html_safe
        end

        expect(rendered_content).to have_selector("div", text: "content")
        expect(rendered_content).not_to have_selector("h1")
        expect(rendered_content).not_to have_selector("p")
      end
    end

    context "with slots" do
      it "renders slots" do
        render_inline(component) do
          it.with_title("title")
          it.with_section("section1")
          it.with_section("section2")
        end

        expect(rendered_content).to have_selector("h1", text: "title")
        expect(rendered_content).to have_selector("p", text: "section1")
        expect(rendered_content).to have_selector("p", text: "section2")
      end

      it "renders slots and content" do
        render_inline(component) do
          it.with_title("title")
          "<div>content</div>".html_safe
        end

        expect(rendered_content).to have_selector("h1", text: "title")
        expect(rendered_content).to have_selector("div", text: "content")
      end
    end

    context "with custom content position" do
      it "renders content between slots" do
        render_inline(component_custom_content_position) do
          it.with_title "title"
          it.with_section "section"
          "<div>content between title and section</div>".html_safe
        end

        expect(rendered_content).to eq("<h1>title</h1><div>content between title and section</div><p>section</p>")
      end
    end
  end
end
