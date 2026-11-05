require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Progress style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Progress" do
    group :size, size: %i[sm md lg xl], label: %i[none inside] do |**args|
      Gustwave::Progress.new(45, **args)
    end

    group :outside_label, content: "Flowbite", label: %i[outside], size: %i[sm md lg xl] do |**args|
      Gustwave::Progress.new(45, **args)
    end

    group :color, color: %i[blue dark red green yellow indigo purple], label: %i[none inside] do |**args|
      Gustwave::Progress.new(45, **args)
    end
  end
end
