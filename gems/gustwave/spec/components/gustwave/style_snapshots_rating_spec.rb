require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Rating style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Rating" do
    group :look, size: %i[sm md lg], value: [ 4.95 ], content: "Rating text" do |value:, size:|
      Gustwave::Rating.new(value, size:)
    end
  end
end
