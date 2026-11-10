require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Select style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Select" do
    group :look, style: %i[default underline], size: %i[sm md lg], validation: %i[none success error] do |**args|
      Gustwave::Form::Select.new(**args)
    end

    group :disabled, style: %i[default underline], validation: %i[none success error], disabled: [ true ] do |**args|
      Gustwave::Form::Select.new(**args)
    end
  end
end
