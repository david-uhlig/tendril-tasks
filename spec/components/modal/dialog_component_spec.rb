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
end
