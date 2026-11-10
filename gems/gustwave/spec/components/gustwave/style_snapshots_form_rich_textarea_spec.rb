require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::RichTextarea style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  # The toolbar moves from the header to the footer, where the frame's
  # corners and the sticky classes change
  footer_toolbar = lambda do |editor|
    editor.with_footer_toolbar
  end

  # Rails numbers the inputs of an editor without a record from a counter,
  # which the snapshot helper doesn't reset, so each combination restarts it.
  build = lambda do |**args|
    ActionText::TagHelper.id = 0
    Gustwave::Form::RichTextarea.new(**args)
  end

  style_snapshot "Gustwave::Form::RichTextarea" do
    group :look, validation: %i[none success error] do |**args|
      build.call(**args)
    end

    group :editor, editor: %i[lexxy trix] do |**args|
      build.call(**args)
    end

    group :sticky, validation: %i[none error], sticky_toolbar: [ true, false ] do |**args|
      build.call(**args)
    end

    group :footer, validation: %i[none error], sticky_toolbar: [ true, false ], slots: footer_toolbar do |**args|
      build.call(**args)
    end
  end
end
