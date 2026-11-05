require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Jumbotron style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Jumbotron" do
    group :centered, centered: [ false, true ] do |**args|
      Gustwave::Jumbotron.new(**args)
    end
  end
end
