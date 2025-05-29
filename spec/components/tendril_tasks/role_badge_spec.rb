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
  end

  context "with admin" do
    it "renders admin badge" do
      user = build_stubbed(:user, role: :admin)
      render_inline(described_class.new(user, id: "role-badge"))
      expect(rendered_content).to have_selector("a[href]", text: "Admin")
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
