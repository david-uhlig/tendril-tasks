require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Link style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Link" do
    group :look, color: %i[default none], underline: %i[hover always none], content: "Read more" do |**args|
      Gustwave::Link.new(**args, href: "/x")
    end
  end
end
