require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Breadcrumb style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Breadcrumb" do
    items = ->(breadcrumb) do
      breadcrumb.with_item("Home", href: "#", icon: :home)
      breadcrumb.with_item("Projects", href: "#")
      breadcrumb.with_item("Flowbite")
    end

    group :look, solid: [ false, true ], separator: %i[chevron slash], slots: items do |**args|
      Gustwave::Breadcrumb.new(**args)
    end
  end
end
