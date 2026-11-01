require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Card style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Card" do
    group :look, tag: %i[div a], horizontal: [ true, false ], content: "Card text" do |**args|
      Gustwave::Card.new(**args, href: ("/x" if args[:tag] == :a))
    end

    # The image slot sets the image through the render block, where view helpers are available
    group :image, tag: %i[div a], horizontal: [ true, false ], content: "Card text",
          slots: ->(card) { card.with_image("/icon.png", alt: "") } do |**args|
      Gustwave::Card.new(**args, href: ("/x" if args[:tag] == :a))
    end
  end
end
