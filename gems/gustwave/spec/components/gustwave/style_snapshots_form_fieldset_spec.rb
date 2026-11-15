require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe "Gustwave::Form::Fieldset style snapshot", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = File.expand_path("../../fixtures/style_snapshots", __dir__)

  style_snapshot "Gustwave::Form::Fieldset" do
    group :validation, validation: %i[none success error],
          slots: ->(fieldset) {
            fieldset.with_label("Notifications")
            fieldset.with_helper_text("Pick any.")
            fieldset.with_validation_message("Pick at least one.")
          },
          content: "<input type=\"checkbox\">".html_safe do |**args|
      Gustwave::Form::Fieldset.new(**args)
    end

    group :label_only, validation: %i[none error],
          slots: ->(fieldset) { fieldset.with_label("Notifications") },
          content: "<input type=\"checkbox\">".html_safe do |**args|
      Gustwave::Form::Fieldset.new(**args)
    end

    group :content, validation: %i[none], content: "<input type=\"checkbox\">".html_safe do |**args|
      Gustwave::Form::Fieldset.new(**args)
    end
  end
end
