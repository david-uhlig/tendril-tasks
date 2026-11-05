require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Stepper style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Stepper" do
    steps = ->(stepper) do
      stepper.with_step("Personal info", state: :complete) { |step| step.with_icon(:check) }
      stepper.with_step("Account info", state: :current)
      stepper.with_step("Confirmation")
    end

    group :style, style: %i[default progress detailed breadcrumb vertical], slots: steps do |**args|
      Gustwave::Stepper.new(**args)
    end
  end
end
