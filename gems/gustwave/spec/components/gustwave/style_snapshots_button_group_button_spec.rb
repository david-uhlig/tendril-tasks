require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::ButtonGroups::Button style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::ButtonGroups::Button" do
    group :look, color: %i[default outline], size: %i[xs sm md lg xl] do |**args|
      Gustwave::ButtonGroups::Button.new("Button", **args)
    end
  end
end
