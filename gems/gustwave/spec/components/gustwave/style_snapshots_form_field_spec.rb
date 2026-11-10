require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Field style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Field" do
    group :validation, validation: %i[none success error],
          slots: ->(field) {
            field.with_label("Your name")
            field.with_control_input
            field.with_helper_text("We'll never share your details.")
            field.with_validation_message("Some message.")
          } do |**args|
      Gustwave::Form::Field.new(**args)
    end

    group :label_only, validation: %i[none error],
          slots: ->(field) {
            field.with_label("Your name")
            field.with_control_input
          } do |**args|
      Gustwave::Form::Field.new(**args)
    end

    group :control_only, validation: %i[none error], slots: ->(field) { field.with_control_input } do |**args|
      Gustwave::Form::Field.new(**args)
    end

    group :content, validation: %i[none], content: "<select></select>".html_safe do |**args|
      Gustwave::Form::Field.new(label: "Plan", **args)
    end
  end
end
