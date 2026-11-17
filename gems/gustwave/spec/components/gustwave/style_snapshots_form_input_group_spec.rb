require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::InputGroups style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::InputGroups::Text" do
    group :look, size: %i[sm md lg], side: %i[leading trailing] do |**args|
      Gustwave::Form::InputGroups::Text.new("@", **args)
    end

    group :icon, side: %i[leading trailing] do |**args|
      Gustwave::Form::InputGroups::Text.new(**args).tap { |addon| addon.with_leading_visual_icon(:user_circle) }
    end
  end

  style_snapshot "Gustwave::Form::InputGroups::Button" do
    group :look, size: %i[sm md lg], side: %i[leading trailing] do |**args|
      Gustwave::Form::InputGroups::Button.new("Copy", **args)
    end
  end

  style_snapshot "Gustwave::Form::InputGroup" do
    group :look, size: %i[sm md lg] do |**args|
      Gustwave::Form::InputGroup.new(**args)
    end
  end
end
