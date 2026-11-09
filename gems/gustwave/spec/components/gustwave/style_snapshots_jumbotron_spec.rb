require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Jumbotron style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Jumbotron" do
    group :centered, centered: [ false, true ] do |**args|
      Gustwave::Jumbotron.new(**args)
    end

    # The background image slot sets the image through the render block, where view helpers are available
    group :background_image, centered: [ false, true ],
          slots: ->(jumbotron) { jumbotron.with_background_image("/hero.jpg") } do |**args|
      Gustwave::Jumbotron.new(**args)
    end
  end
end
