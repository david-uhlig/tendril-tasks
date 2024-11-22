# frozen_string_literal: true

require "rails_helper"

RSpec.describe RoleBadgeComponent, type: :component do
  context "with regular user" do
    it "does not render" do
      user = build_stubbed(:user, role: :user)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(page).not_to have_selector("span#role-badge")
    end
  end

  context "with editor" do
    it "renders editor badge" do
      user = build_stubbed(:user, role: :editor)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(page).to have_selector("span#role-badge")
      expect(page).to have_content("Redakteur")
    end
  end

  context "with admin" do
    it "renders admin badge" do
      user = build_stubbed(:user, role: :admin)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(page).to have_selector("span#role-badge")
      expect(page).to have_content("Admin")
    end
  end

  context "with custom options" do
    it "renders custom css class" do
      user = build_stubbed(:user, role: :admin)
      render_inline(described_class.new(user, id: "role-badge", class: "custom-class"))
      expect(page).to have_selector("span.custom-class")
    end
  end
end
