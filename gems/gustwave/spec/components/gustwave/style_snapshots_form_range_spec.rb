require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Range style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Range" do
    group :size, size: %i[sm md lg] do |**args|
      Gustwave::Form::Range.new(**args)
    end

    group :validation, validation: %i[none success error] do |**args|
      Gustwave::Form::Range.new(**args)
    end
  end
end
