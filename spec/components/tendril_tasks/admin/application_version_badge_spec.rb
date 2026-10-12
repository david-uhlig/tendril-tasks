# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::Admin::ApplicationVersionBadge, type: :component do
  context "with a git commit" do
    before { allow(AppConfig).to receive(:git_commit).and_return("abc1234") }

    it "renders the version and commit links" do
      render_inline(described_class.new)
      expect(page).to have_link(TendrilTasks::VERSION)
      expect(page).to have_link("abc1234", href: "https://github.com/david-uhlig/tendril-tasks/commit/abc1234")
    end

    it "spaces the links apart and wraps the commit in parentheses" do
      render_inline(described_class.new)
      # The badge is a flex container, which drops whitespace between the links
      expect(page).to have_css("span.gap-1", text: "#{TendrilTasks::VERSION} (abc1234)")
    end
  end

  context "with a released version" do
    before { stub_const("TendrilTasks::VERSION", "0.7.2") }

    it "links the version to its release" do
      render_inline(described_class.new)
      expect(page).to have_link("0.7.2", href: "https://github.com/david-uhlig/tendril-tasks/releases/tag/v0.7.2")
    end
  end

  context "with a development version" do
    before { stub_const("TendrilTasks::VERSION", "0.8.0.dev") }

    it "links the version to the list of releases" do
      render_inline(described_class.new)
      expect(page).to have_link("0.8.0.dev", href: "https://github.com/david-uhlig/tendril-tasks/releases")
    end
  end

  context "without a git commit" do
    before { allow(AppConfig).to receive(:git_commit).and_return(nil) }

    it "renders only the version link" do
      render_inline(described_class.new)
      expect(page).to have_link(TendrilTasks::VERSION)
      expect(page).to have_css("a", count: 1)
    end
  end
end
