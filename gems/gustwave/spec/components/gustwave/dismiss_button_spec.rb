# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::DismissButton, type: :component do
  it "dismisses the target" do
    render_inline(described_class.new("my-modal"))

    expect(page).to have_selector("button[type='button'][data-dismiss-target='#my-modal']")
  end

  it "renders an inline button with a close icon by default" do
    render_inline(described_class.new("my-modal"))

    expect(page).to have_selector("button.bg-transparent.rounded-xs > svg[aria-hidden='true']")
  end

  it "labels the button and its screen reader text as dismissing by default" do
    I18n.with_locale(:en) { render_inline(described_class.new("my-modal")) }

    expect(page).to have_selector("button[aria-label='Dismiss'] > span.sr-only", text: "Dismiss")
  end

  it "localizes the default label" do
    I18n.with_locale(:de) { render_inline(described_class.new("my-modal")) }

    expect(page).to have_selector("button[aria-label='Schließen'] > span.sr-only", text: "Schließen")
  end

  it "renders the text as label and screen reader text" do
    render_inline(described_class.new("my-modal", "Close modal"))

    expect(page).to have_selector("button[aria-label='Close modal'] > span.sr-only", text: "Close modal")
  end

  it "renders block content without sr-only markup" do
    render_inline(described_class.new("my-modal")) { "Got it" }

    expect(page).to have_selector("button", text: "Got it")
    expect(page).not_to have_selector("button span.sr-only")
  end

  it "renders the given theme" do
    render_inline(described_class.new("my-modal", theme: :default))

    expect(page).not_to have_selector("button.rounded-xs")
  end

  it "renders no icon with icon: nil" do
    render_inline(described_class.new("my-modal", icon: nil))

    expect(page).to have_selector("button")
    expect(page).not_to have_selector("button svg")
  end

  it "passes the icon options to the icon" do
    render_inline(described_class.new("my-modal", icon_options: { class: "w-6 h-6" }))

    expect(page).to have_selector("button > svg.w-6.h-6")
  end

  it "merges data and aria attributes with the defaults" do
    I18n.with_locale(:en) { render_inline(described_class.new("my-modal", data: { foo: "1" }, aria: { describedby: "hint" })) }

    expect(page).to have_selector("button[data-foo='1'][data-dismiss-target='#my-modal']")
    expect(page).to have_selector("button[aria-label='Dismiss'][aria-describedby='hint']")
  end

  it "passes the color and size to the button" do
    render_inline(described_class.new("my-modal", color: :dark, size: :lg))

    expect(page).to have_selector("button.text-gray-400.p-2")
  end

  it "passes the class to the button" do
    render_inline(described_class.new("my-modal", class: "extra-class"))

    expect(page).to have_selector("button.extra-class.bg-transparent")
  end
end
