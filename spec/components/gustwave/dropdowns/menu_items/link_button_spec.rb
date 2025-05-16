require "rails_helper"

RSpec.describe Gustwave::Dropdowns::MenuItems::LinkButton, type: :component do
  with_options selector: "a" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new)
    end

    it "renders anchor tag" do
      expect(rendered_content).to have_selector("a[href='#']")
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("a.flex.items-center.w-full")
    end
  end

  context "with icon argument" do
    before(:context) do
      render_inline(described_class.new(icon: :check))
    end

    it "renders icon" do
      expect(rendered_content).to have_selector('a>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end

    it "renders icon styling" do
      expect(rendered_content).to have_selector('a>svg.h-\[1\.5em\]')
    end
  end

  context "with trailing icon argument" do
    before(:context) do
      render_inline(described_class.new(trailing_icon: :check))
    end

    it "renders icon" do
      expect(rendered_content).to have_selector('a>svg>path[d="M5 11.917 9.724 16.5 19 7.5"]')
    end

    it "renders icon styling" do
      expect(rendered_content).to have_selector('a>svg.h-\[1\.5em\].ms-auto')
    end
  end

  context "with Gustwave::Button slots" do
    let(:component) { described_class.new }

    it "responds to leading_icon slot" do
      expect(component).to respond_to(:leading_icon)
    end

    it "responds to trailing_icon slot" do
      expect(component).to respond_to(:trailing_icon)
    end
  end
end
