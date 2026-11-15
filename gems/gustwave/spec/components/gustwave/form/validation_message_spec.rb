# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::ValidationMessage, type: :component do
  it "renders the errors of a bound attribute as a sentence, in the error state, under the field's message ID" do
    record = invalid_task
    render_inline(described_class.new(:title, form: form_builder(record)))

    message = page.find("p#task_title_validation_message")
    expect(message.text).to eq(record.errors[:title].to_sentence.upcase_first)
    expect(class_set(message[:class])).to eq(class_set("mt-2 text-sm text-red-600 dark:text-red-500"))
  end

  it "renders nothing without errors and without a block" do
    render_inline(described_class.new(:title, form: form_builder))

    expect(page).to have_no_css("p")
  end

  it "renders the block instead of the errors" do
    render_inline(described_class.new(:title, form: form_builder(invalid_task))) { "Pick another title." }

    expect(page).to have_css("p#task_title_validation_message.text-red-600", text: "Pick another title.")
  end

  it "renders an unbound message with the caller's ID, state and attributes" do
    render_inline(described_class.new(id: "plan-message", validation: :success, class: "mb-4")) { "Saved." }

    expect(page).to have_css("p#plan-message.text-green-600.mb-4", text: "Saved.")
  end

  it "looks like a helper text without a state" do
    render_inline(described_class.new) { "Note." }

    expect(class_set(page.find("p")[:class])).to eq(class_set("mt-2 text-sm text-gray-500 dark:text-gray-400"))
    expect(page.find("p")[:id]).to be_nil
  end

  it "lets the caller's validation win over the errors" do
    render_inline(described_class.new(:title, form: form_builder(invalid_task), validation: :none))

    expect(page).to have_css("p.text-gray-500")
  end

  it "raises for an attribute without a form" do
    expect { described_class.new(:title) }.to raise_error(ArgumentError, /needs `form:`/)
  end
end
