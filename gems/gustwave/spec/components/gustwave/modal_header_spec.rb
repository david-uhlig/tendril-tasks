require "rails_helper"

RSpec.describe Gustwave::ModalHeader, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "div", modal_id: "modal"

  it "renders the title as an h3 with the modal's title id and the heading's classes" do
    render_inline(described_class.new("Title text", modal_id: "modal"))

    expect(page).to have_selector("h3#modal-title.text-xl.font-semibold", text: "Title text")
  end

  it "applies the title options" do
    render_inline(described_class.new("Title text", modal_id: "modal", title_options: { class: "truncate" }))

    expect(page).to have_selector("h3#modal-title.truncate", text: "Title text")
  end

  it "renders a block title" do
    render_inline(Gustwave::Modal.new(id: "modal")) { |modal| modal.with_header { "Block title" } }

    expect(page).to have_selector("h3#modal-title", text: "Block title")
  end

  it "renders a close button that hides the modal, with a screen reader label" do
    I18n.with_locale(:de) { render_inline(described_class.new("Title text", modal_id: "modal")) }

    expect(page).to have_selector("button[data-modal-hide='modal'] > span.sr-only", text: "Schließen")
  end

  it "labels the close button in English" do
    I18n.with_locale(:en) { render_inline(described_class.new("Title text", modal_id: "modal")) }

    expect(page).to have_selector("button[data-modal-hide='modal'] > span.sr-only", text: "Close")
  end

  it "renders no close button with close_button: false" do
    render_inline(described_class.new("Title text", modal_id: "modal", close_button: false))

    expect(page).not_to have_selector("button")
  end
end
