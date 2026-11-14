require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::InlineField style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::InlineField" do
    group :validation, validation: %i[none success error],
          slots: ->(field) {
            field.with_label("Notify me")
            field.with_control_toggle
            field.with_helper_text("At most one email a week.")
            field.with_validation_message("Some message.")
          } do |**args|
      Gustwave::Form::InlineField.new(**args)
    end

    group :label_only, validation: %i[none error],
          slots: ->(field) {
            field.with_label("Notify me")
            field.with_control_toggle
          } do |**args|
      Gustwave::Form::InlineField.new(**args)
    end

    group :disabled, validation: %i[none success error],
          slots: ->(field) {
            field.with_label("Notify me")
            field.with_control_toggle(disabled: true)
          } do |**args|
      Gustwave::Form::InlineField.new(**args)
    end

    group :control_only, validation: %i[none], slots: ->(field) { field.with_control_toggle } do |**args|
      Gustwave::Form::InlineField.new(**args)
    end

    group :checkbox, validation: %i[none error],
          slots: ->(field) {
            field.with_label("Remember me")
            field.with_control_checkbox
            field.with_helper_text("For 30 days on this device.")
          } do |**args|
      Gustwave::Form::InlineField.new(**args)
    end

    group :checkbox_disabled, validation: %i[none],
          slots: ->(field) {
            field.with_label("Remember me")
            field.with_control_checkbox(disabled: true)
          } do |**args|
      Gustwave::Form::InlineField.new(**args)
    end

    group :content, validation: %i[none], content: "<input type=\"checkbox\">".html_safe do |**args|
      Gustwave::Form::InlineField.new(label: "Remember me", **args)
    end
  end
end
