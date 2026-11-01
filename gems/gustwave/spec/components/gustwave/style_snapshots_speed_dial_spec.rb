require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::SpeedDial style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::SpeedDial" do
    actions = ->(dial) do
      dial.with_action("Edit", icon: :edit)
      dial.with_action("Share", icon: :link)
    end

    group :placement, position: %i[none bottom_right bottom_left top_right top_left],
                      direction: %i[up down left right], slots: actions do |**args|
      Gustwave::SpeedDial.new(**args)
    end

    group :look, shape: %i[round square], label_display: %i[tooltip inside outside], slots: actions do |**args|
      Gustwave::SpeedDial.new(**args)
    end
  end
end
