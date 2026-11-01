require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Timeline style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Timeline" do
    items = ->(timeline) do
      timeline.with_item do |item|
        item.with_date "February 2022"
        item.with_title "Without a marker"
        item.with_body "Body"
      end
      timeline.with_item do |item|
        item.with_marker_icon :calendar_month
        item.with_title "With a marker"
      end
    end

    group :orientation, orientation: %i[vertical horizontal], slots: items do |**args|
      Gustwave::Timeline.new(**args)
    end
  end
end
