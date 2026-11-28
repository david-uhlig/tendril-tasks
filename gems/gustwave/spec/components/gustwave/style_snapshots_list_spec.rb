require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::List style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::List" do
    # Three items, so a divided list shows the first, middle and last positions
    items = ->(list) do
      list.with_item "Plain"
      list.with_item "With an icon", icon: :check
      list.with_item "Third"
    end

    # Without a marker, the list takes the marker of its tag, so tag alone covers the default
    group :tag, tag: %i[ul ol], slots: items do |**args|
      Gustwave::List.new(**args)
    end

    group :marker, tag: %i[ul ol], marker: %i[disc decimal none], slots: items do |**args|
      Gustwave::List.new(**args)
    end

    group :color, color: %i[default none], nested: [ false, true ], slots: items do |**args|
      Gustwave::List.new(**args)
    end

    group :layout, orientation: %i[vertical horizontal], divided: [ false, true ], slots: items do |**args|
      Gustwave::List.new(**args)
    end
  end
end
