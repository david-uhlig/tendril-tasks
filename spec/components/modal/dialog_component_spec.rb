require "rails_helper"

RSpec.describe Modal::DialogComponent, type: :component do
  let(:component) { described_class.new("confirm-dialog") }

  context "with buttons" do
    before do
      component.with_button { "Abbrechen" }
      component.with_button { "Bestätigen" }
    end

    it "renders every button" do
      render_inline(component)

      expect(page).to have_button("Abbrechen")
      expect(page).to have_button("Bestätigen")
    end

    it "makes each button hide the modal with the given id" do
      render_inline(component)

      expect(page).to have_css("button[data-modal-hide='confirm-dialog']", text: "Abbrechen")
      expect(page).to have_css("button[data-modal-hide='confirm-dialog']", text: "Bestätigen")
    end

    it "renders the buttons outside of a form" do
      render_inline(component)

      expect(page).to have_no_css("form")
    end
  end

  context "without buttons" do
    it "renders only the close button of the shell" do
      render_inline(component)

      expect(page).to have_css("button[data-modal-hide='confirm-dialog']", count: 1)
    end
  end

  context "with a form path" do
    let(:component) do
      described_class.new("confirm-dialog", form_path: "/tasks/42", form_method: :delete)
    end

    before do
      component.with_button { "Löschen" }
    end

    it "posts the buttons to the form path" do
      render_inline(component)

      expect(page).to have_css("form[action='/tasks/42']", text: "Löschen")
    end

    it "sends the form method as a hidden field" do
      render_inline(component)

      expect(page).to have_css("form[action='/tasks/42'] input[name='_method'][value='delete']", visible: :all)
    end

    it "keeps the buttons hiding the modal" do
      render_inline(component)

      expect(page).to have_css("form[action='/tasks/42'] button[data-modal-hide='confirm-dialog']")
    end
  end
end
