require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Radio style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Radio" do
    group :look, color: %i[blue red green purple teal yellow orange], validation: %i[none success error] do |**args|
      Gustwave::Form::Radio.new(**args)
    end

    group :disabled, disabled: [ true ] do |**args|
      Gustwave::Form::Radio.new(**args)
    end
  end
end
