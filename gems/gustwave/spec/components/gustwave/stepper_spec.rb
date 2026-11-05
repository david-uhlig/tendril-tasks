# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Stepper, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "ol"
  it_behaves_like "a component with configurable html attributes", component_class: Gustwave::Stepper::Step, selector: "li"

  def render_steps(style: :default, &block)
    render_inline(described_class.new(style:)) do |stepper|
      if block
        block.call(stepper)
      else
        stepper.with_step("Personal info", state: :complete)
        stepper.with_step("Account info", state: :current)
        stepper.with_step("Confirmation")
      end
    end
  end

  describe "steps" do
    it "renders each step as a list item, in order" do
      render_steps

      expect(page).to have_selector("ol > li", count: 3)
      expect(page.all("li").map { _1.text(:all) }).to eq([ "1Personal info", "2Account info", "3Confirmation" ])
    end

    it "numbers the steps from 1" do
      render_steps

      expect(page).to have_selector("li span.me-2", text: "1")
      expect(page).to have_selector("li span.me-2", text: "2")
      expect(page).to have_selector("li span.me-2", text: "3")
    end

    it "renders the title from the block" do
      render_inline(described_class.new) do |stepper|
        stepper.with_step(state: :current) do
          "Personal <span class=\"hidden sm:inline-flex sm:ms-2\">Info</span>".html_safe
        end
      end

      expect(page).to have_selector("li", text: "Personal Info")
      expect(page).to have_selector("li span.hidden.sm\\:inline-flex", text: "Info")
    end
  end

  describe "state" do
    it "marks the current step with aria-current" do
      render_steps

      expect(page).to have_selector("li[aria-current='step']", count: 1)
      expect(page).to have_selector("li[aria-current='step']", text: "Account info")
    end

    it "marks no step as current by default" do
      render_inline(described_class.new) { |stepper| stepper.with_step("Personal info") }

      expect(page).not_to have_selector("li[aria-current]")
    end

    it "colors a complete and a current step blue, and an upcoming one gray" do
      render_steps

      expect(page).to have_selector("li.text-blue-600", count: 2)
      expect(page).to have_selector("li.text-gray-500", count: 0)
      expect(page).to have_selector("li.flex.items-center:not(.text-blue-600)")
    end
  end

  describe "connectors" do
    it "draws a connector from every step but the last in the default style" do
      render_steps

      connected = page.all("li").map { |li| li[:class].include?("after:content-['']") }

      expect(connected).to eq([ true, true, false ])
    end

    it "draws a connector from every step but the last in the progress style" do
      render_steps(style: :progress)

      connected = page.all("li").map { |li| li[:class].include?("after:content-['']") }

      expect(connected).to eq([ true, true, false ])
    end

    it "colors the connector of a complete or current step" do
      render_steps(style: :progress)

      connectors = page.all("li").map { |li| li[:class].include?("after:border-blue-100") }

      expect(connectors).to eq([ true, true, false ])
    end
  end

  describe "breadcrumb" do
    it "renders a separator on all but the last step" do
      render_steps(style: :breadcrumb)

      separators = page.all("li").map { |li| li.all(:xpath, "./*[local-name()='svg']").size }

      expect(separators).to eq([ 1, 1, 0 ])
    end
  end

  describe "detailed" do
    it "renders each title as an h3 with its description" do
      render_inline(described_class.new(style: :detailed)) do |stepper|
        stepper.with_step("User info", state: :current, description: "Step details here")
        stepper.with_step("Company info", description: "Step details here")
      end

      expect(page).to have_selector("li h3", text: "User info")
      expect(page).to have_selector("li h3", text: "Company info")
      expect(page).to have_selector("li p.text-sm", text: "Step details here", count: 2)
    end

    it "doesn't render the description in other styles" do
      render_inline(described_class.new(style: :default)) do |stepper|
        stepper.with_step("User info", description: "Step details here")
      end

      expect(page).not_to have_selector("p", text: "Step details here")
    end
  end

  describe "progress" do
    it "renders the text for screen readers only" do
      render_steps(style: :progress)

      expect(page).to have_selector("li span.sr-only", text: "Personal info")
      expect(page).to have_selector("li span.sr-only", text: "Confirmation")
    end
  end

  describe "vertical" do
    it "renders the numbered title of each step" do
      render_steps(style: :vertical)

      expect(page).to have_selector("li h3", text: "2. Account info")
      expect(page).to have_selector("li h3", text: "3. Confirmation")
    end

    it "colors a complete step green, a current step blue and an upcoming step gray" do
      render_steps(style: :vertical)

      boxes = page.all("li > div").map { |box| box[:class] }

      expect(boxes[0]).to include("bg-green-50")
      expect(boxes[1]).to include("bg-blue-100")
      expect(boxes[2]).to include("bg-gray-100")
      expect(boxes[2]).not_to include("bg-green-50")
    end

    it "doesn't render an alert role or a screen reader duplicate of the title" do
      render_steps(style: :vertical)

      expect(page).not_to have_selector("[role='alert']")
      expect(page).not_to have_selector("span.sr-only")
    end
  end

  describe "icon" do
    it "renders the icon in place of the number" do
      render_inline(described_class.new) do |stepper|
        stepper.with_step("Personal info", state: :complete) { |step| step.with_icon(:check) }
        stepper.with_step("Account info")
      end

      expect(page).to have_selector("li svg[aria-hidden='true'].me-2\\.5")
      expect(page).to have_selector("li", text: "Personal info")
      expect(page).not_to have_selector("li span.me-2", text: "1")
      expect(page).to have_selector("li span.me-2", text: "2")
    end

    it "renders the icon of each style at its size" do
      render_inline(described_class.new(style: :progress)) do |stepper|
        stepper.with_step("Personal info", state: :complete) { |step| step.with_icon(:check) }
      end

      expect(page).to have_selector("li span svg.w-3\\.5.h-3\\.5")
    end

    it "renders the icon outline by default and lets the caller pick the theme" do
      render_inline(described_class.new(style: :vertical)) do |stepper|
        stepper.with_step("Social accounts", state: :current) { |step| step.with_icon(:arrow_right) }
        stepper.with_step("Review") { |step| step.with_icon(:check_circle, theme: :solid) }
      end

      expect(page).to have_selector("li svg.w-4.h-4 path[d]")
      expect(page).to have_selector("li svg.w-4.h-4[fill='currentColor']")
    end
  end

  describe "numbers" do
    it "renders no number for a step outside a stepper" do
      render_inline(Gustwave::Stepper::Step.new("Personal info"))

      expect(page).to have_selector("li", text: "Personal info")
      expect(page).not_to have_selector("li span.me-2")
    end
  end
end
