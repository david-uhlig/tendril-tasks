require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Tabs style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Tabs" do
    group :interactive, style: %i[default underline pills full_width none], vertical: [ true, false ],
          slots: ->(tabs) {
            tabs.with_tab_button("Profile", id: "profile", selected: true) { |tab| tab.with_panel { "Profile content" } }
            tabs.with_tab_button("Settings", id: "settings") { |tab| tab.with_panel { "Settings content" } }
            tabs.with_tab_button("Billing", id: "billing", disabled: true) { |tab| tab.with_panel { "Billing content" } }
          } do |**args|
      Gustwave::Tabs.new(id: "tabs", **args)
    end
  end
end
