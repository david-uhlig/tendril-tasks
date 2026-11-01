# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Timeline, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "ol"
  it_behaves_like "a component with configurable html attributes", component_class: Gustwave::Timeline::Item, selector: "li"

  describe "orientation" do
    it "renders a vertical line by default" do
      render_inline(described_class.new) { |timeline| timeline.with_item { "Event" } }

      expect(page).to have_selector("ol.border-s")
    end

    it "renders the items side by side when horizontal" do
      render_inline(described_class.new(orientation: :horizontal)) { |timeline| timeline.with_item { "Event" } }

      expect(page).to have_selector("ol.sm\\:flex")
      expect(page).not_to have_selector("ol.border-s")
    end

    it "renders the track, connector and content wrapper for a horizontal item" do
      render_inline(described_class.new(orientation: :horizontal)) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          "<p>Event</p>".html_safe
        end
      end

      expect(page).to have_selector("li > div.flex.items-center.h-6 > span + div.h-0\\.5")
      expect(page).to have_selector("li > div.mt-3 > p", text: "Event")
    end

    it "renders no track, connector or content wrapper for a vertical item" do
      render_inline(described_class.new) { |timeline| timeline.with_item { "Event" } }

      expect(page).not_to have_selector("li > div.flex.items-center")
      expect(page).not_to have_selector("div.h-0\\.5")
      expect(page).not_to have_selector("li > div.mt-3")
    end

    it "doesn't indent a horizontal item" do
      render_inline(described_class.new(orientation: :horizontal)) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          "Event"
        end
      end

      expect(page).to have_selector("li.relative")
      expect(page).not_to have_selector("li.ms-4")
      expect(page).not_to have_selector("li.ms-6")
    end
  end

  describe "marker" do
    it "renders a dot when there is no marker" do
      render_inline(described_class.new) { |timeline| timeline.with_item { "Event" } }

      expect(page).to have_selector("li > div[aria-hidden='true'].rounded-full")
      expect(page).to have_selector("li.ms-4")
    end

    it "renders an icon marker and indents a vertical item" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          "Event"
        end
      end

      expect(page).to have_selector("li > span > svg[aria-hidden='true'].w-2\\.5")
      expect(page).not_to have_selector("li > span > svg.h-6")
      expect(page).not_to have_selector("li > div[aria-hidden='true']")
      expect(page).to have_selector("li.ms-6")
      expect(page).not_to have_selector("li.ms-4")
    end

    it "renders an image marker as an avatar" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_marker_image "/icon.png", alt: "Bonnie"
          "Event"
        end
      end

      expect(page).to have_selector("li > span > img[alt='Bonnie'].rounded-full.w-6.shadow-lg")
      expect(page).to have_selector("li.ms-6")
    end
  end

  describe "items" do
    it "renders each item as its own li" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item { "First" }
        timeline.with_item { "Second" }
      end

      expect(page).to have_selector("ol > li", count: 2)
      expect(page).to have_selector("li", text: "First")
      expect(page).to have_selector("li", text: "Second")
    end

    it "renders an item's block content after its marker" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          "<p>Event</p>".html_safe
        end
      end

      expect(page).to have_selector("li > span + p", text: "Event")
    end

    it "renders an item without content" do
      render_inline(described_class.new) { |timeline| timeline.with_item }

      expect(page).to have_selector("ol > li > div[aria-hidden='true']")
    end

    it "renders block content on the timeline after the items" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item { "Event" }
        "<li id='extra'>x</li>".html_safe
      end

      expect(page).to have_selector("li + li#extra")
    end
  end
end
