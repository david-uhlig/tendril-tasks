require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::BottomNavigation style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::BottomNavigation" do
    items = ->(navigation) do
      navigation.with_item_button("Home", icon: :home)
      navigation.with_item_link("Wallet", href: "#", icon: :wallet)
      navigation.with_item_button("Profile", icon: :user_circle, active: true)
    end

    group :placement, position: %i[fixed sticky none], floating: [ false, true ], slots: items do |**args|
      Gustwave::BottomNavigation.new(**args)
    end

    group :items, bordered: [ false, true ], label_display: %i[inside tooltip], slots: items do |**args|
      Gustwave::BottomNavigation.new(**args)
    end
  end
end
