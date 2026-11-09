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

  describe "close button slot" do
    it "customizes the close button with with_close_button" do
      render_inline(described_class.new("Title text", modal_id: "modal")) do |header|
        header.with_close_button(text: "Dismiss dialog")
      end

      expect(page).to have_selector("button[data-modal-hide='modal'] > span.sr-only", text: "Dismiss dialog")
      expect(page).to have_selector("button", count: 1)
    end

    it "accepts the text as a positional argument" do
      render_inline(described_class.new("Title text", modal_id: "modal")) do |header|
        header.with_close_button("Dismiss dialog")
      end

      expect(page).to have_selector("button[data-modal-hide='modal'] > span.sr-only", text: "Dismiss dialog")
    end

    it "lets caller classes win over the defaults" do
      render_inline(described_class.new("Title text", modal_id: "modal")) do |header|
        header.with_close_button(class: "text-red-500")
      end

      expect(page).to have_selector("button[data-modal-hide='modal'].text-red-500")
      expect(page).not_to have_selector("button.text-gray-400")
    end

    it "keeps the hide trigger when the caller adds data" do
      render_inline(described_class.new("Title text", modal_id: "modal")) do |header|
        header.with_close_button(data: { foo: "1" })
      end

      expect(page).to have_selector("button[data-foo='1'][data-modal-hide='modal']")
    end

    it "renders no close button with close_button: false, even when one is set" do
      render_inline(described_class.new("Title text", modal_id: "modal", close_button: false)) do |header|
        header.with_close_button(text: "Dismiss dialog")
      end

      expect(page).not_to have_selector("button")
    end
  end
end
