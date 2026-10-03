require "rails_helper"

RSpec.describe Form::CoordinatorPicker::ModalComponent, type: :component do
  it "labels the close button" do
    render_inline(described_class.new(assigned: [], suggestions: []))

    expect(rendered_content).to have_selector("button[data-modal-hide] span.sr-only", text: "Schließen")
  end
end
