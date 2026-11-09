require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::ListGroup::Item style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::ListGroup::Item" do
    group :look, tag: %i[li a button], active: [ false, true ], disabled: [ false, true ] do |**args|
      Gustwave::ListGroup::Item.new("Profile", **args)
    end

    group :position, list_position: %i[only first middle last] do |list_position:|
      Gustwave::ListGroup::Item.new("Profile").tap { |item| item.apply_slot_context(list_position:) }
    end

    group :icon, tag: %i[a button] do |**args|
      Gustwave::ListGroup::Item.new("Profile", icon: :user_circle, **args)
    end

    group :trailing_visual, tag: %i[a button] do |**args|
      Gustwave::ListGroup::Item.new("Profile", **args).tap { |item| item.with_trailing_visual_icon(:chevron_right, theme: :outline) }
    end
  end
end
