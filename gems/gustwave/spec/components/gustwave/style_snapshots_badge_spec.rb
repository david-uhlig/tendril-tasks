# frozen_string_literal: true

require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Badge style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  colors = %i[none base default dark red green yellow indigo purple pink]
  sizes = %i[xs sm md lg xl 2xl]
  with_leading_and_trailing_visuals = lambda do |badge|
    badge.with_leading_visual_icon(:check)
    badge.with_trailing_visual_icon(:check)
  end
  with_dismiss_button = ->(badge) { badge.with_dismiss_button }

  style_snapshot "Gustwave::Badge" do
    # The hover style depends on the tag (only links and buttons get it) and the color
    group :tag_and_hover, tag: %i[div span button a], color: colors do |**args|
      Gustwave::Badge.new("New", **args)
    end

    # The border and outline classes depend on the color
    group :color_border_outline, color: colors, border: [ false, true ], outline: [ false, true ] do |**args|
      Gustwave::Badge.new("New", **args)
    end

    group :type, type: %i[none button submit reset] do |**args|
      Gustwave::Badge.new("New", **args)
    end

    # Size sets the text and visual classes. Without text the badge renders
    # as a round visual-only badge, which the pill option also affects.
    group :size, size: sizes, text: [ "New", nil ], pill: [ false, true ],
                 slots: with_leading_and_trailing_visuals do |**args|
      Gustwave::Badge.new(args[:text], size: args[:size], pill: args[:pill])
    end

    # The dismiss button color is derived from the badge color
    group :dismiss_button_color, color: colors, slots: with_dismiss_button do |**args|
      Gustwave::Badge.new("New", **args)
    end

    # The dismiss button size and padding are derived from the badge size
    group :dismiss_button_size, size: sizes, slots: with_dismiss_button do |**args|
      Gustwave::Badge.new("New", **args)
    end
  end
end
