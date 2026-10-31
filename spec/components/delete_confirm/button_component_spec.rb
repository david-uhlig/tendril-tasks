require "rails_helper"

RSpec.describe DeleteConfirm::ButtonComponent, type: :component do
  def button
    page.find("button")
  end

  it "renders a button that toggles the confirmation modal" do
    render_inline(described_class.new(text: "Delete", target_modal_id: "confirm-modal"))

    expect(button["data-modal-target"]).to eq("confirm-modal")
    expect(button["data-modal-toggle"]).to eq("confirm-modal")
  end

  it "renders an id derived from the modal, so a morph doesn't reuse it as another button" do
    render_inline(described_class.new(text: "Delete", target_modal_id: "confirm-modal"))

    expect(button["id"]).to eq("confirm-modal-toggle")
  end

  it "keeps a given id" do
    render_inline(described_class.new(text: "Delete", target_modal_id: "confirm-modal", id: "custom"))

    expect(button["id"]).to eq("custom")
  end

  context "with data attributes" do
    before do
      render_inline(described_class.new(text: "Delete", target_modal_id: "confirm-modal", data: { foo: "bar" }))
    end

    it "renders the given data attributes" do
      expect(button["data-foo"]).to eq("bar")
    end

    it "keeps the modal target" do
      expect(button["data-modal-target"]).to eq("confirm-modal")
    end

    it "keeps the modal toggle" do
      expect(button["data-modal-toggle"]).to eq("confirm-modal")
    end
  end
end
