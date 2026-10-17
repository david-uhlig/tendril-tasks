require "rails_helper"
require "gustwave/test/style_snapshots"

module Gustwave
  module Specs
    module StyleSnapshotMacro
      # A component of its own, so the fixture only changes with the harness.
      class Example < Gustwave::Component
        base "inline-flex"
        part :label, "font-medium"
        variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
        toggle :pill, "rounded-full"

        renders_one :label, ->(text) { tag.span(text, class: classes(:label)) }

        def initialize(size: DEFAULT, pill: false)
          select_options(size:, pill:)
        end

        def call
          tag.div(id: generate_random_id(prefix: "example"), class: classes) { safe_join([ label, content ].compact) }
        end
      end
    end
  end
end

# Runs the style_snapshot macro against a committed fixture. Regenerate it
# with UPDATE_STYLE_SNAPSHOTS=1 after changing the harness's output format.
RSpec.describe "Gustwave::Test::StyleSnapshots#style_snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../../fixtures/style_snapshot_macro", __dir__)

  style_snapshot "Gustwave::Specs::StyleSnapshotMacro::Example" do
    group :look, size: %i[sm md], pill: [ false, true ] do |**args|
      Gustwave::Specs::StyleSnapshotMacro::Example.new(**args)
    end
    group :content, content: "Text", slots: ->(example) { example.with_label("Label") } do
      Gustwave::Specs::StyleSnapshotMacro::Example.new
    end
  end
end
