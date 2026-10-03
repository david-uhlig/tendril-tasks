require "rails_helper"

RSpec.describe Modal::DialogComponent, type: :component do
  it "labels the close button" do
    render_inline(described_class.new("dialog"))

    expect(rendered_content).to have_selector("button[data-modal-hide='dialog'] span.sr-only", text: "Schließen")
  end
end
