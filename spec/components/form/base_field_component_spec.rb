# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::BaseFieldComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(:task, Task.new, ActionView::Base.empty, {}) }

  context "with an ActiveRecord model and no label" do
    it "renders the translated attribute name as label" do
      render_inline(described_class.new(form, :project)) { "input" }

      expect(page).to have_selector("label", text: Task.human_attribute_name(:project))
    end
  end
end
