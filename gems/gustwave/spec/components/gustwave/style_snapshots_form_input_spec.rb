require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Input style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Input" do
    group :look, size: %i[sm md lg], validation: %i[none success error] do |**args|
      Gustwave::Form::Input.new(**args)
    end

    group :disabled, validation: %i[none success error], disabled: [ true ] do |**args|
      Gustwave::Form::Input.new(**args)
    end

    group :icon, size: %i[sm md lg], validation: %i[none error] do |**args|
      Gustwave::Form::Input.new(icon: :envelope, **args)
    end

    # The action sits at the end of the input, with and without a leading icon. The slot is set in the render block, where the input's size is known.
    group :trailing_action, size: %i[sm md lg], icon: [ nil, :envelope ],
          slots: ->(input) { input.with_trailing_action_button("Search", type: :submit) } do |**args|
      Gustwave::Form::Input.new(**args)
    end

    # The group selects the joined edges through the slot context
    group :joined, joined: %i[none start end both], size: %i[sm md lg] do |joined:, **args|
      Gustwave::Form::Input.new(**args).tap { |input| input.apply_slot_context(joined:) }
    end

    group :joined_icon, joined: %i[start end both] do |joined:, **args|
      Gustwave::Form::Input.new(icon: :envelope, **args).tap { |input| input.apply_slot_context(joined:) }
    end

    group :type, type: Gustwave::Form::Input.option_values(:type) do |**args|
      Gustwave::Form::Input.new(**args)
    end
  end
end
