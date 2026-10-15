# frozen_string_literal: true

require "rails_helper"

# Renders every preview example, so that previews don't break unnoticed.
RSpec.describe "Gustwave previews", type: :component do
  ViewComponent::Preview.all.each do |preview|
    preview.examples.each do |example|
      it "renders #{preview.preview_name}/#{example}" do
        render_preview(example, from: preview)
        expect(rendered_content).to be_present
      end
    end
  end
end
