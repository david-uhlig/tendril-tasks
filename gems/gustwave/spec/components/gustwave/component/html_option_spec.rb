# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The html: option", type: :component do
  describe "on a component" do
    it "renders an attribute named like an option next to the option" do
      render_inline(Gustwave::Stepper.new(style: :vertical, html: { style: "color: red" }))

      expect(page).to have_css "ol.space-y-4[style='color: red']"
    end

    it "reaches the root of Tabs next to its style" do
      render_inline(Gustwave::Tabs.new(style: :underline, html: { style: "max-width: 40rem" })) do |tabs|
        tabs.with_tab_button("One")
      end

      expect(page).to have_css "div[style='max-width: 40rem']"
    end

    it "wins over the flat attribute, also for class and data" do
      render_inline(Gustwave::Link.new("x", id: "flat", class: "flat mt-1", data: { a: 1 }, html: { id: "html", class: "probe", data: { b: 2 } }))

      link = page.find("a")
      expect(link[:id]).to eq "html"
      expect(link[:class].split).to include "probe", "font-medium"
      expect(link[:class].split).not_to include "flat"
      expect(link["data-b"]).to eq "2"
      expect(link["data-a"]).to be_nil
    end

    it "accepts string keys" do
      render_inline(Gustwave::Link.new("x", html: { "class" => "probe", "data-x" => "1" }))

      expect(page).to have_css "a.probe[data-x='1']"
    end

    it "accepts a string key named like an option" do
      render_inline(Gustwave::Stepper.new(style: :vertical, html: { "style" => "color: red" }))

      expect(page).to have_css "ol.space-y-4[style='color: red']"
    end

    it "ignores nil and an empty hash" do
      plain = render_inline(Gustwave::Link.new("x")).to_html

      expect(render_inline(Gustwave::Link.new("x", html: nil)).to_html).to eq plain
      expect(render_inline(Gustwave::Link.new("x", html: {})).to_html).to eq plain
    end

    it "raises for anything but a hash" do
      expect { Gustwave::Link.new("x", html: "nope") }
        .to raise_error(ArgumentError, 'html: takes a Hash of HTML attributes, got "nope"')
    end

    it "passes through a wrapper to the component it renders" do
      render_inline(Gustwave::AvatarPlaceholder.new(html: { "data-probe": "1" }))

      expect(page).to have_css "[data-probe='1']", count: 1
    end
  end

  describe "on a slot setter" do
    it "reaches the component the slot builds" do
      render_inline(Gustwave::Timeline.new) do |timeline|
        timeline.with_item(html: { "data-probe": "item", class: "probe" }) { "Event" }
      end

      expect(page).to have_css "li.probe.mb-10[data-probe='item']"
    end

    it "passes an attribute named like the parent's and the child's option" do
      render_inline(Gustwave::Stepper.new(style: :vertical)) do |stepper|
        stepper.with_step("One", html: { style: "color: blue" })
      end

      expect(page).to have_css "li[style='color: blue']"
    end

    it "reaches the markup a slot builds" do
      render_inline(Gustwave::Navbar.new) do |navbar|
        navbar.with_item_generic(html: { "data-probe": "1" }) { "g" }
      end

      expect(page).to have_css "li[data-probe='1']"
      expect(page).not_to have_css "li[html]"
    end

    it "reaches a tab's panel" do
      render_inline(Gustwave::Tabs.new) do |tabs|
        tabs.with_tab_button("One") do |tab|
          tab.with_panel(class: "p-9", html: { "data-probe": "panel" }) { "p" }
        end
      end

      expect(page).to have_css "div.p-9[role='tabpanel'][data-probe='panel']"
    end

    it "reaches a field's helper text" do
      render_inline(Gustwave::Form::Field.new(label: "L")) do |field|
        field.with_control_input
        field.with_helper_text("h", html: { "data-probe": "1" })
      end

      expect(page).to have_css "p[data-probe='1']"
    end
  end

  describe "the error for a rejected value" do
    it "names html: for an option named like an HTML attribute" do
      expect { Gustwave::Tabs.new(style: "max-width: 40rem") }
        .to raise_error(Gustwave::Options::UnknownValueError,
                        /Expected one of: .*\nFor the HTML attribute, pass html: \{ style: "max-width: 40rem" \}\.\nWhen Gustwave isn't strict/)
    end

    it "has no hint for any other option" do
      expect { Gustwave::Buttons::Default.new("x", color: 5) }
        .to raise_error(Gustwave::Options::UnknownValueError) { |error| expect(error.message).not_to include("html:") }
    end
  end
end
