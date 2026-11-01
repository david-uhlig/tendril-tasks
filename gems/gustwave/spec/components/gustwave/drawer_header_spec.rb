# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::DrawerHeader, type: :component do
  it_behaves_like "a text and block content renderer", selector: "h5#info-title", drawer_id: "info"

  it "labels the title with the drawer's title id and keeps it when given title options" do
    render_inline(described_class.new("Info", drawer_id: "info", title_options: { class: "x", id: "other" }))

    expect(page).to have_selector("h5#info-title.x")
    expect(page).not_to have_selector("#other")
  end

  it "renders the title with semibold text and a bottom margin" do
    render_inline(described_class.new("Info", drawer_id: "info"))

    expect(page).to have_selector("h5#info-title.font-semibold.mb-4")
  end

  it "renders an icon before the title" do
    render_inline(described_class.new("Info", drawer_id: "info", icon: :info_circle))

    expect(page).to have_selector("h5 svg.me-2\\.5")
  end

  context "with a close button" do
    it "hides the drawer through data-drawer-hide" do
      render_inline(described_class.new("Info", drawer_id: "info"))

      expect(page).to have_selector("button[data-drawer-hide=info]")
    end

    it "carries no drawer target, dismiss target or aria-controls" do
      render_inline(described_class.new("Info", drawer_id: "info"))

      expect(page).to have_selector("button")
      expect(page).not_to have_selector("button[data-drawer-target]")
      expect(page).not_to have_selector("button[data-dismiss-target]")
      expect(page).not_to have_selector("button[aria-controls]")
    end

    it "renders a sr-only English label" do
      I18n.with_locale(:en) { render_inline(described_class.new("Info", drawer_id: "info")) }

      expect(page).to have_selector("button > span.sr-only", text: "Close", visible: :all)
    end

    it "renders a sr-only German label" do
      I18n.with_locale(:de) { render_inline(described_class.new("Info", drawer_id: "info")) }

      expect(page).to have_selector("button > span.sr-only", text: "Schließen", visible: :all)
    end

    it "renders an icon in the button" do
      render_inline(described_class.new("Info", drawer_id: "info"))

      expect(page).to have_selector("button svg")
    end

    it "renders no button with close_button: false" do
      render_inline(described_class.new("Info", drawer_id: "info", close_button: false))

      expect(page).not_to have_selector("button")
    end
  end

  context "with an edge" do
    it "renders the handle as the toggle of the drawer, with its ARIA attributes" do
      render_inline(described_class.new("Info", drawer_id: "info", edge: true))

      expect(page).to have_selector("div[data-drawer-toggle=info][aria-controls=info]")
    end

    it "renders the handle bar and the title within the handle" do
      render_inline(described_class.new("Info", drawer_id: "info", edge: true))

      expect(page).to have_selector("div[data-drawer-toggle=info] > span.left-1\\/2")
      expect(page).to have_selector("div[data-drawer-toggle=info] h5#info-title")
    end

    it "renders no button, even with close_button: true" do
      render_inline(described_class.new("Info", drawer_id: "info", edge: true, close_button: true))

      expect(page).not_to have_selector("button")
    end

    it "renders a medium weight title without a bottom margin" do
      render_inline(described_class.new("Info", drawer_id: "info", edge: true))

      expect(page).to have_selector("h5#info-title.font-medium")
      expect(page).not_to have_selector("h5#info-title.font-semibold")
      expect(page).not_to have_selector("h5#info-title.mb-4")
    end
  end
end
