require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::DeviceMockup style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::DeviceMockup" do
    group :look, device: %i[phone iphone android tablet laptop desktop smartwatch], color: %i[dark light none] do |**args|
      Gustwave::DeviceMockup.new(**args)
    end
  end
end
