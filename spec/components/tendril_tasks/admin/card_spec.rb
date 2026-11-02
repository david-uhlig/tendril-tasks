# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::Admin::Card, type: :component do
  it "renders a badge's icon at 16px without Badge's negative margin" do
    render_inline(described_class.new) do |card|
      card.with_badge("Open", icon: :check)
    end

    expect(page).to have_selector("svg.h-4.mx-0")
    expect(page).not_to have_selector("svg.-mx-px")
  end
end
