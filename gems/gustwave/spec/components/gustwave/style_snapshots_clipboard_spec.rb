require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Clipboard style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Clipboard" do
    group :look, color: %i[default alternative light], size: %i[xs md], content: "Copy" do |**args|
      Gustwave::Clipboard.new(target_id: "npm-install", **args)
    end

    group :theme, theme: %i[default inline], content: "Copy" do |**args|
      Gustwave::Clipboard.new(target_id: "npm-install", **args)
    end

    group :icon_only, color: %i[default light], size: %i[xs md] do |**args|
      Gustwave::Clipboard.new(target_id: "api-key", **args)
    end

    group :icon, color: %i[default light], size: %i[xs md], content: "Copy",
          slots: ->(clipboard) { clipboard.with_icon(:clipboard_check) } do |**args|
      Gustwave::Clipboard.new(target_id: "npm-install", **args)
    end

    group :tooltip, size: %i[xs md], content: "Copy", slots: ->(clipboard) { clipboard.with_tooltip } do |**args|
      Gustwave::Clipboard.new(target_id: "npm-install", **args)
    end

    group :tooltip_click, content: "Copy", slots: ->(clipboard) { clipboard.with_tooltip(placement: :bottom, trigger_event: :click) } do |**args|
      Gustwave::Clipboard.new(target_id: "npm-install", **args)
    end

    group :parts, size: %i[md], content: "Copy" do |**args|
      Gustwave::Clipboard.new(target_id: "npm-install",
                              message_options: { class: "font-bold" },
                              copied_message_options: { class: "text-green-700" },
                              **args)
    end
  end
end
