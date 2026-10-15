# frozen_string_literal: true

require "rails_helper"

RSpec.describe TendrilTasks::Tasks::ApplicationStatus, type: :component do
  def icon_paths(node)
    node.at_css("svg").css("path").map { _1["d"] }
  end

  def paths_of(icon)
    icon_paths(render_inline(Gustwave::Icon.new(icon)))
  end

  def trigger
    page.find("button[data-dropdown-toggle]")
  end

  {
    received: [ :inbox, "bg-gray-100" ],
    under_review: [ :file_search, "bg-cyan-100" ],
    interviewing: [ :messages, "bg-blue-100" ],
    on_hold: [ :clock, "bg-yellow-100" ],
    accepted: [ :badge_check, "bg-green-100" ],
    rejected: [ :close_circle, "bg-red-100" ],
    withdrawn: [ :ban, "bg-indigo-100" ]
  }.each do |status, (icon, color)|
    context "when #{status}" do
      it "shows the #{icon} icon in #{color}" do
        expected = paths_of(icon)
        render_inline(described_class.new(build_stubbed(:task_application, status:)))

        expect(trigger[:class]).to include(color, "rounded-full")
        expect(icon_paths(Nokogiri::HTML.fragment(trigger.native.to_html))).to eq expected
      end
    end
  end

  it "shows each status's icon in the dropdown" do
    expected = paths_of(:clock)
    render_inline(described_class.new(build_stubbed(:task_application, status: :received)))

    option = page.find("button[name=status][value=on_hold]")
    expect(icon_paths(Nokogiri::HTML.fragment(option.native.to_html))).to eq expected
  end
end
