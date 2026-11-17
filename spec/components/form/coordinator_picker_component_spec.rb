# frozen_string_literal: true

require "rails_helper"

RSpec.describe Form::CoordinatorPickerComponent, type: :component do
  let(:task) { TaskForm.new(coordinator_ids: [ create(:user).id ]) }
  let(:form) { Gustwave::FormBuilder.new(:task, task, vc_test_controller.view_context, {}) }
  let(:fieldset) { page.find("fieldset") }

  it "groups the assigned coordinators and the edit button in a fieldset with a legend" do
    render_inline(described_class.new(form, :coordinators))

    expect(fieldset).to have_selector("legend", text: TaskForm.human_attribute_name(:coordinators))
    expect(fieldset).to have_text(task.coordinators.first.name)
    expect(fieldset).to have_button("edit-coordinator-assignment")
    expect(page).not_to have_selector("label")
  end

  it "uses a custom label as the legend" do
    render_inline(described_class.new(form, :coordinators, "Leads"))

    expect(fieldset).to have_selector("legend", text: "Leads")
  end

  it "shows the validation message and names it in aria-describedby" do
    task.errors.add(:coordinators, "needs one")
    render_inline(described_class.new(form, :coordinators))

    message = fieldset.find("p", text: "Needs one")
    expect(fieldset[:"aria-describedby"]).to include(message[:id])
  end
end
