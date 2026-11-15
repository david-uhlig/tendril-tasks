require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::ValidationMessage style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::ValidationMessage" do
    group :validation, validation: %i[none success error], content: "Choose a plan to continue." do |**args|
      Gustwave::Form::ValidationMessage.new(**args)
    end
  end
end
