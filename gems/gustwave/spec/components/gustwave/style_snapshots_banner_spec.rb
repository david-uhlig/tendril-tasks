require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Banner style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Banner" do
    group :look, position: %i[top bottom], floating: [ true, false ], content: "Banner text" do |**args|
      Gustwave::Banner.new(**args)
    end

    group :align, align: %i[center start], content: "Banner text" do |**args|
      Gustwave::Banner.new(**args)
    end

    group :dismissible, position: %i[top bottom], floating: [ true, false ], content: "Banner text",
          slots: ->(banner) { banner.with_dismiss_button } do |**args|
      Gustwave::Banner.new(**args, id: "banner")
    end
  end
end
