# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::RoleBadge, type: :component do
  context "with regular user" do
    it "does not render" do
      user = build_stubbed(:user, role: :user)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(rendered_content).not_to have_selector("a")
    end
  end

  context "with editor" do
    it "renders editor badge" do
      user = build_stubbed(:user, role: :editor)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(rendered_content).to have_selector("a[href]", text: "Redaktion")
    end

    it "keeps its blue background in dark mode" do
      user = build_stubbed(:user, role: :editor)
      render_inline(described_class.new(user))
      expect(page).to have_selector("a.border[class~='dark:bg-blue-900'][class~='dark:text-blue-300']")
      expect(page).not_to have_selector("a[class~='dark:bg-gray-700']")
    end
  end

  context "with admin" do
    it "keeps its purple background in dark mode" do
      user = build_stubbed(:user, role: :admin)
      render_inline(described_class.new(user))
      expect(page).to have_selector("a.border[class~='dark:bg-purple-900'][class~='dark:text-purple-300']")
      expect(page).not_to have_selector("a[class~='dark:bg-gray-700']")
    end
  end

  context "with admin" do
    it "renders admin badge" do
      user = build_stubbed(:user, role: :admin)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(rendered_content).to have_selector("a[href]", text: "Admin")
    end
  end

  describe "color" do
    def badge_classes
      Nokogiri::HTML.fragment(rendered_content).at_css("a")["class"]
    end

    { admin: :purple, editor: :default }.each do |role, color|
      it "is #{color} for #{role}" do
        render_inline(Gustwave::Badge.new("Badge", tag: :a, color:, size: :sm, border: true, class: described_class::ROLE_DARK_COLORS[role]))
        expected = badge_classes

        render_inline(described_class.new(build_stubbed(:user, role:)))

        expect(badge_classes).to eq expected
      end
    end
  end

  context "with custom options" do
    it "renders custom css class" do
      user = build_stubbed(:user, role: :admin)
      render_inline(described_class.new(user, id: "role-badge", class: "custom-class"))
      expect(rendered_content).to have_selector("a.custom-class", text: "Admin")
    end
  end
end
