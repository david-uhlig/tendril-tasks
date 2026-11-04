require "rails_helper"

RSpec.describe Gustwave::ButtonGroup, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div.inline-flex"

  context "with default options" do
    before(:each) do
      render_inline(described_class.new) do |group|
        group.with_button("Profile")
      end
    end

    it "renders the group element" do
      expect(rendered_content).to have_selector("div.inline-flex.rounded-md.shadow-xs[role=group]")
    end

    it "renders the button" do
      expect(rendered_content).to have_button("Profile", class: %w[rounded-lg border])
    end
  end

  context "with a custom role" do
    it "renders the given role" do
      render_inline(described_class.new(role: "toolbar")) { |group| group.with_button("Profile") }

      expect(rendered_content).to have_selector("div[role=toolbar]")
      expect(rendered_content).not_to have_selector("div[role=group]")
    end

    it "removes the role when given nil" do
      render_inline(described_class.new(role: nil)) { |group| group.with_button("Profile") }

      expect(rendered_content).to have_selector("div.inline-flex")
      expect(rendered_content).not_to have_selector("div[role]")
    end
  end

  context "with three buttons" do
    before(:each) do
      render_inline(described_class.new) do |group|
        group.with_button("First")
        group.with_button("Middle")
        group.with_button("Last")
      end
    end

    it "renders the first button with a start rounding" do
      expect(rendered_content).to have_button("First", class: %w[rounded-s-lg border])
    end

    it "renders the middle button with shared top and bottom borders only" do
      middle = page.find_button("Middle")

      expect(middle[:class]).to include("border-y")
      expect(middle[:class]).not_to include("rounded-s-lg", "rounded-e-lg")
    end

    it "renders the last button with an end rounding" do
      expect(rendered_content).to have_button("Last", class: %w[rounded-e-lg border])
    end

    it "renders the buttons in order" do
      labels = page.all("button").map(&:text)

      expect(labels).to eq(%w[First Middle Last])
    end
  end

  context "with two buttons" do
    it "renders the first and last positions" do
      render_inline(described_class.new) do |group|
        group.with_button("First")
        group.with_button("Last")
      end

      expect(rendered_content).to have_button("First", class: %w[rounded-s-lg])
      expect(rendered_content).to have_button("Last", class: %w[rounded-e-lg])
    end
  end

  context "with outline" do
    it "outlines every button" do
      render_inline(described_class.new(outline: true)) do |group|
        group.with_button("First")
        group.with_button("Last")
      end

      expect(rendered_content).to have_button("First", class: %w[border-gray-900])
      expect(rendered_content).to have_button("Last", class: %w[border-gray-900])
    end

    it "lets a button's own color take precedence" do
      render_inline(described_class.new(outline: true)) do |group|
        group.with_button("First")
        group.with_button("Last", color: :default)
      end

      expect(rendered_content).to have_button("First", class: %w[border-gray-900])
      expect(rendered_content).to have_button("Last", class: %w[border-gray-200])
    end
  end

  context "with links" do
    it "renders anchors without a type attribute and passes aria through" do
      render_inline(described_class.new(role: nil)) do |group|
        group.with_button("Profile", tag: :a, href: "#", aria: { current: "page" }, class: "text-blue-700")
        group.with_button("Settings", tag: :a, href: "#")
      end

      expect(rendered_content).to have_selector("a[href='#'][aria-current=page].text-blue-700", text: "Profile")
      expect(rendered_content).to have_selector("a[href='#']", text: "Settings")
      expect(rendered_content).not_to have_selector("a[type]")
    end
  end

  context "with icons" do
    before(:each) do
      render_inline(described_class.new) do |group|
        group.with_button("Profile") { |button| button.with_leading_visual_icon(:user_circle) }
        group.with_button("Settings")
      end
    end

    it "renders the icon inside the button" do
      expect(rendered_content).to have_selector("button svg")
    end

    it "lays out the button as an inline flex row" do
      expect(page.find_button("Profile")[:class]).to include("inline-flex", "items-center")
    end
  end

  context "with block content" do
    it "renders the content after the buttons and keeps the last button's rounding" do
      render_inline(described_class.new) do |group|
        group.with_button("First")
        group.with_button("Last")
        '<span id="extra">Extra</span>'.html_safe
      end

      expect(rendered_content).to have_selector("span#extra", text: "Extra")
      expect(rendered_content).to have_button("Last", class: %w[rounded-e-lg])
      expect(page.find("div.inline-flex").native.children.last.name).to eq("span")
    end
  end
end
