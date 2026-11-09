require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Footer style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Footer" do
    group :sticky, sticky: [ false, true ], content: "Copyright" do |**args|
      Gustwave::Footer.new(**args)
    end
  end
end
