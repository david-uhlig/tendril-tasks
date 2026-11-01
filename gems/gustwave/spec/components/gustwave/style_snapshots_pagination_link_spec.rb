require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Pagination::Link style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Pagination::Link" do
    group :look, size: %i[sm md], active: [ false, true ] do |**args|
      Gustwave::Pagination::Link.new("1", href: "#", **args)
    end
  end
end
