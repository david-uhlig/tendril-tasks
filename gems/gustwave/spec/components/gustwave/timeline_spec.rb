# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Timeline, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "ol"
  it_behaves_like "a component with configurable html attributes", component_class: Gustwave::Timeline::Item, selector: "li"

  describe "orientation" do
    it "renders a vertical line by default" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("ol.border-s")
    end

    it "renders the items side by side when horizontal" do
      render_inline(described_class.new(orientation: :horizontal)) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("ol.sm\\:flex")
      expect(page).not_to have_selector("ol.border-s")
    end

    it "renders the horizontal track, connector and content for a horizontal item" do
      render_inline(described_class.new(orientation: :horizontal)) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("li > div.flex.items-center")
      expect(page).to have_selector("li > div.flex.items-center div.h-0\\.5")
      expect(page).to have_selector("li > div.mt-3 h3", text: "Title")
    end

    it "renders no track, connector or content wrapper for a vertical item" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title"
        end
      end

      expect(page).not_to have_selector("li > div.flex.items-center")
      expect(page).not_to have_selector("div.h-0\\.5")
      expect(page).not_to have_selector("li > div.mt-3")
    end

    it "gives horizontal items the relative root and no indent" do
      render_inline(described_class.new(orientation: :horizontal)) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("li.relative")
      expect(page).not_to have_selector("li.ms-4")
      expect(page).not_to have_selector("li.ms-6")
    end
  end

  describe "marker" do
    it "renders a dot when there is no marker" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("li > div[aria-hidden='true'].rounded-full")
      expect(page).to have_selector("li.ms-4")
    end

    it "renders an icon marker and indents a vertical item" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_marker_icon :calendar_month
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("li > span > svg[aria-hidden='true'].w-2\\.5")
      expect(page).not_to have_selector("li > span > svg.h-6")
      expect(page).to have_selector("li.ms-6")
      expect(page).not_to have_selector("li.ms-4")
    end

    it "renders an image marker as an avatar" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_marker_image "/icon.png", alt: "Bonnie"
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("li > span > img[alt='Bonnie'].rounded-full.w-6.shadow-lg")
    end
  end

  describe "date" do
    it "localizes a Date and sets datetime" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_date Date.new(2022, 2, 1)
        end
      end

      expect(page).to have_selector("time[datetime='2022-02-01']", text: I18n.l(Date.new(2022, 2, 1)))
    end

    it "uses an explicit datetime with a string value" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_date "February 2022", datetime: "2022-02"
        end
      end

      expect(page).to have_selector("time[datetime='2022-02']", text: "February 2022")
    end

    it "renders a string without a datetime attribute" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_date "February 2022"
        end
      end

      expect(page).to have_selector("time:not([datetime])", text: "February 2022")
    end

    it "renders block content" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_date { "Yesterday" }
        end
      end

      expect(page).to have_selector("time", text: "Yesterday")
    end
  end

  describe "title" do
    it "renders an h3 with the title classes by default" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title"
        end
      end

      expect(page).to have_selector("h3.text-lg.font-semibold.text-gray-900", text: "Title")
    end

    it "renders the heading level given by tag" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title", tag: :h4
        end
      end

      expect(page).to have_selector("h4.text-lg", text: "Title")
    end

    it "adds the caller's classes" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title", class: "mb-1"
        end
      end

      expect(page).to have_selector("h3.text-lg.font-semibold.mb-1", text: "Title")
    end

    it "renders block content" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title { "Block title" }
        end
      end

      expect(page).to have_selector("h3", text: "Block title")
    end
  end

  describe "body" do
    it "renders a paragraph with the body classes" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_body "Body"
        end
      end

      expect(page).to have_selector("p.text-base.text-gray-500.mb-4", text: "Body")
    end

    it "renders block content" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_body { "Block body" }
        end
      end

      expect(page).to have_selector("p", text: "Block body")
    end
  end

  describe "order" do
    it "renders the date, title and body in that order" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_date "February 2022"
          item.with_title "Title"
          item.with_body "Body"
        end
      end

      expect(page).to have_selector("time + h3")
      expect(page).to have_selector("h3 + p")
    end

    it "renders block content after the body" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_body("Body")
          "<a href='#'>CTA</a>".html_safe
        end
      end

      expect(page).to have_selector("p + a", text: "CTA")
    end
  end

  describe "items" do
    it "renders each item as its own li" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "First"
        end
        timeline.with_item do |item|
          item.with_title "Second"
        end
      end

      expect(page).to have_selector("ol > li", count: 2)
      expect(page).to have_selector("li h3", text: "First")
      expect(page).to have_selector("li h3", text: "Second")
    end

    it "renders block content on the timeline after the items" do
      render_inline(described_class.new) do |timeline|
        timeline.with_item do |item|
          item.with_title "Title"
        end
        "<li id='extra'>x</li>".html_safe
      end

      expect(page).to have_selector("li + li#extra")
    end
  end
end
