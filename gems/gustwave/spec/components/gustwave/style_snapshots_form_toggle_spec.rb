require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Toggle style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Toggle" do
    group :look, size: %i[sm md lg], color: %i[blue red green purple yellow teal orange] do |**args|
      Gustwave::Form::Toggle.new(**args) { "Toggle me" }
    end

    group :disabled, disabled: [ true ] do |**args|
      Gustwave::Form::Toggle.new(**args) { "Toggle me" }
    end
  end
end
