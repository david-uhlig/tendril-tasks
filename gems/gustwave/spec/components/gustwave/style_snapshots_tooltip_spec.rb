require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Tooltip style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Tooltip" do
    group :look, color: %i[dark light none], arrow: [ true, false ] do |**args|
      Gustwave::Tooltip.new("Tooltip text", **args)
    end
  end
end
