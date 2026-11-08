require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Progress style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Progress" do
    group :look, size: %i[sm md lg xl], color: %i[blue dark red green yellow indigo purple] do |**args|
      Gustwave::Progress.new(45, **args)
    end

    group :label, color: %i[blue dark red green yellow indigo purple], content: "45%" do |**args|
      Gustwave::Progress.new(45, **args)
    end
  end
end
