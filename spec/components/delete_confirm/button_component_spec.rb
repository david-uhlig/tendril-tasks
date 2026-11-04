# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeleteConfirm::ButtonComponent, type: :component do
  it "renders an id derived from the modal, so a morph doesn't reuse it as another button" do
    rendered = render_inline(described_class.new(text: "Delete", target_modal_id: "confirm-modal"))

    expect(rendered.at_css("button")["id"]).to eq("confirm-modal-toggle")
  end

  it "keeps a given id" do
    rendered = render_inline(described_class.new(text: "Delete", target_modal_id: "confirm-modal", id: "custom"))

    expect(rendered.at_css("button")["id"]).to eq("custom")
  end
end
