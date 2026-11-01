require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Timeline style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Timeline" do
    items = ->(timeline) do
      timeline.with_item { "Without a marker" }
      timeline.with_item do |item|
        item.with_marker_icon :calendar_month
        "With a marker"
      end
    end

    group :orientation, orientation: %i[vertical horizontal], slots: items do |**args|
      Gustwave::Timeline.new(**args)
    end
  end
end
