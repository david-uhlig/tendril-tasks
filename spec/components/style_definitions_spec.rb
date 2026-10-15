require "rails_helper"

# Styling definitions are checked when they're first resolved. Resolving every
# app component's definition here catches a bad declaration even if no other
# spec renders that component.
RSpec.describe "Styling definitions" do
  Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/components"))

  Gustwave::Component.descendants.select { |component| component.name&.start_with?("TendrilTasks::", "Form::") }
                     .sort_by(&:name).each do |component|
    it "resolves for #{component.name}" do
      expect { component.style_definition }.not_to raise_error
    end
  end
end
