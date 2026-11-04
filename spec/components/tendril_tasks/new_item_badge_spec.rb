# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::NewItemBadge, type: :component do
  it "keeps its green background in dark mode" do
    render_inline(described_class.new)

    expect(page).to have_selector("span.border[class~='dark:bg-green-900'][class~='dark:text-green-300']")
    expect(page).not_to have_selector("span[class~='dark:bg-gray-700']")
  end
end
