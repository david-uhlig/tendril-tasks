require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Textarea style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Textarea" do
    group :look, validation: %i[none success error] do |**args|
      Gustwave::Form::Textarea.new(**args)
    end

    group :disabled, validation: %i[none success error], disabled: [ true ] do |**args|
      Gustwave::Form::Textarea.new(**args)
    end
  end
end
