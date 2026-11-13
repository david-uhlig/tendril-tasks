require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Textarea style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  # With a header and a footer the textarea renders in the frame, which has
  # all four of its parts
  framed_slots = lambda do |textarea|
    textarea.with_header { "Bold" }
    textarea.with_footer { "Post" }
  end

  style_snapshot "Gustwave::Form::Textarea" do
    group :look, validation: %i[none success error] do |**args|
      Gustwave::Form::Textarea.new(**args)
    end

    group :disabled, validation: %i[none success error], disabled: [ true ] do |**args|
      Gustwave::Form::Textarea.new(**args)
    end

    group :framed, validation: %i[none success error], slots: framed_slots do |**args|
      Gustwave::Form::Textarea.new(**args)
    end
  end
end
