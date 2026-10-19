require "rails_helper"

RSpec.describe Gustwave::Spinner, type: :component do
  with_options selector: "div" do
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:each) do
      I18n.with_locale(:de) { render_inline(described_class.new) }
    end

    it "renders a div container" do
      expect(rendered_content).to have_selector("div")
    end

    it "renders the loading spinner icon" do
      expect(rendered_content).to have_selector("div[role='status'] > svg > path")
    end

    it "marks the container with the status role" do
      expect(rendered_content).to have_selector("div[role='status']")
    end

    it "hides the icon from screen readers" do
      expect(rendered_content).to have_selector("svg[aria-hidden='true']")
    end

    it "labels the spinner with the default text" do
      expect(rendered_content).to have_selector("span.sr-only", text: "Lädt ...")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("svg.inline.animate-spin")
    end

    it "renders the default color" do
      expect(rendered_content).to have_selector("svg.text-gray-200.fill-blue-600")
    end

    it "renders in the default size" do
      expect(rendered_content).to have_selector("svg.h-6.w-6")
    end
  end

  context "with text argument" do
    it "renders the text as the screen reader label" do
      render_inline(described_class.new("Saving"))

      expect(rendered_content).to have_selector("div[role='status'] > span.sr-only", exact_text: "Saving")
    end

    it "renders the text over block content" do
      render_inline(described_class.new("Saving")) { '<span class="sr-only">Blocked</span>'.html_safe }

      expect(rendered_content).to have_selector("span.sr-only", exact_text: "Saving")
      expect(rendered_content).not_to have_content("Blocked")
    end
  end

  context "with block content" do
    it "renders the block as the screen reader label" do
      render_inline(described_class.new) { '<span class="sr-only">Saving</span>'.html_safe }

      expect(rendered_content).to have_selector("div[role='status'] > span.sr-only", exact_text: "Saving")
    end

    it "replaces the default label" do
      I18n.with_locale(:de) do
        render_inline(described_class.new) { '<span class="sr-only">Saving</span>'.html_safe }
      end

      expect(rendered_content).not_to have_content("Lädt ...")
    end
  end

  context "with configure_icon" do
    it "passes the icon options on to the icon" do
      spinner = described_class.new
      spinner.configure_icon(size: :lg)
      render_inline(spinner)

      expect(rendered_content).to have_selector("svg.h-7.w-7")
    end
  end

  context "with color argument" do
    it "renders the color styling" do
      render_inline(described_class.new(color: :red))
      expect(rendered_content).to have_selector("svg.text-gray-200.fill-red-600")
    end
  end

  context "with size argument" do
    it "renders the size styling" do
      render_inline(described_class.new(size: :lg))
      expect(rendered_content).to have_selector("svg.h-7.w-7")
    end
  end

  context "with position argument" do
    it "renders the position styling" do
      render_inline(described_class.new(position: :top_left))
      expect(rendered_content).to have_selector("div.absolute.top-0.left-0")
    end
  end

  context "with align argument" do
    it "renders the align styling" do
      render_inline(described_class.new(align: :right))
      expect(rendered_content).to have_selector("div.text-right")
    end
  end
end
