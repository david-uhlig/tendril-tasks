require "rails_helper"

RSpec.describe Form::SubmitButtonGroupComponent, type: :component do
  let(:form) { ActionView::Helpers::FormBuilder.new(:task, nil, ActionView::Base.empty, {}) }
  let(:component) { described_class.new(form) }

  context "when rendering is disabled" do
    it "renders nothing" do
      component = described_class.new(form, render_if: false)
      component.with_button_regular("Speichern")

      render_inline(component)

      expect(rendered_content).to be_blank
    end
  end

  context "when rendering is enabled" do
    it "renders the buttons" do
      component.with_button_regular("Speichern")

      render_inline(component)

      expect(page).to have_button("Speichern")
    end
  end

  context "with a regular button" do
    it "submits the form with the default submit type name" do
      component.with_button_regular("Speichern")

      render_inline(component)

      expect(page).to have_button("Speichern", type: "submit", name: "task[submit_type]")
    end

    it "submits the default value save" do
      component.with_button_regular("Speichern")

      render_inline(component)

      expect(page).to have_button("Speichern", name: "task[submit_type]", value: "save")
    end

    it "submits a custom value when given one" do
      component.with_button_regular("Speichern und neue Aufgabe", value: "save_and_new_task")

      render_inline(component)

      expect(page).to have_button("Speichern und neue Aufgabe",
                                  name: "task[submit_type]",
                                  value: "save_and_new_task")
    end

    it "submits a custom name when given one" do
      component.with_button_regular("Speichern", name: "custom_submit")

      render_inline(component)

      expect(page).to have_button("Speichern", name: "custom_submit")
    end
  end

  context "with a delete button" do
    it "opens the confirmation modal it targets" do
      component.with_button_delete("Löschen", target_modal_id: "confirm-task-delete")

      render_inline(component)

      expect(page).to have_button("Löschen", type: "button")
      expect(page).to have_css("button[data-modal-toggle='confirm-task-delete']", text: "Löschen")
    end

    it "does not submit the form" do
      component.with_button_delete("Löschen", target_modal_id: "confirm-task-delete")

      render_inline(component)

      expect(page).to have_no_css("button[name='task[submit_type]']")
    end
  end
end
