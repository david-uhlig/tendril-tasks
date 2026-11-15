# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Fieldset, type: :component do
  def gustwave_form(object = task)
    form_builder(object, builder: Gustwave::FormBuilder)
  end

  # Two checkboxes of one +multiple+ attribute, one field each
  def render_group(form, **options)
    render_inline(described_class.new(:title, form:, **options)) do
      form.check_box(:title, { multiple: true, label: "A" }, "a", nil) +
        form.check_box(:title, { multiple: true, label: "B" }, "b", nil)
    end
  end

  describe "markup" do
    it "renders a fieldset without classes, with the legend first and the caller's attributes" do
      render_group(gustwave_form, class: "mb-6", disabled: true)

      fieldset = page.find("fieldset")
      expect(fieldset[:class]).to eq("mb-6")
      expect(fieldset[:disabled]).to be_present
      expect(fieldset.all(:xpath, "./*").map(&:tag_name)).to eq(%w[legend div div])
    end

    it "renders the legend from Rails' label text, with the label's classes" do
      render_group(gustwave_form)

      legend = page.find("fieldset > legend")
      expect(legend.text).to eq("Title")
      expect(legend[:for]).to be_nil
      expect(class_set(legend[:class])).to eq(class_set("mb-2 text-sm font-medium text-gray-900 dark:text-white"))
    end

    it "renders no legend for label: false" do
      render_group(gustwave_form, label: false)

      expect(page).to have_no_css("legend")
    end

    it "renders the caller's classes on the label slot" do
      render_inline(described_class.new) do |fieldset|
        fieldset.with_label("Plan", class: "sr-only")
        "content"
      end

      expect(page).to have_css("legend.sr-only", text: "Plan")
    end

    it "renders the helper text and the message after the group, and names both on the fieldset" do
      render_group(gustwave_form, helper_text: "Pick any.", validation: :error, validation_message: "Pick one.")

      fieldset = page.find("fieldset")
      expect(fieldset.all(:xpath, "./*").map(&:tag_name)).to eq(%w[legend div div p p])
      expect(fieldset["aria-describedby"]).to eq("task_title_helper_text task_title_validation_message")
      expect(page).to have_css("p#task_title_helper_text", text: "Pick any.")
      expect(page).to have_css("p#task_title_validation_message.text-red-600", text: "Pick one.")
    end

    it "keeps the caller's aria-describedby" do
      render_group(gustwave_form, helper_text: "Pick any.", aria: { describedby: "own" })

      expect(page.find("fieldset")["aria-describedby"]).to eq("own task_title_helper_text")
    end

    it "sets no aria-describedby without texts" do
      render_group(gustwave_form)

      expect(page.find("fieldset")["aria-describedby"]).to be_nil
    end
  end

  describe "a group with errors" do
    it "renders the attribute's errors once, on the fieldset, and keeps the state on every field" do
      record = invalid_task
      render_group(gustwave_form(record))

      sentence = record.errors[:title].to_sentence.upcase_first
      expect(page).to have_css("p", count: 1)
      expect(page).to have_css("fieldset > p#task_title_validation_message.text-red-600", text: sentence)
      expect(page.find("fieldset")["aria-describedby"]).to eq("task_title_validation_message")
      expect(page).to have_css("legend.text-red-700")
      expect(page).to have_css("input[type='checkbox'][aria-invalid='true']", count: 2)
      expect(page).to have_css("label.text-red-700", count: 2)
      expect(page).to have_no_css("input[aria-describedby]")
    end
  end

  describe "without a form" do
    it "renders only what the caller sets, with generated IDs" do
      render_inline(described_class.new(label: "Plan", helper_text: "Pick one.", validation: :error,
                                        validation_message: "Choose a plan.")) { "content" }

      fieldset = page.find("fieldset")
      helper, message = fieldset.all("p").to_a
      expect(fieldset).to have_css("legend", text: "Plan")
      expect(helper[:id]).to match(/\Afield-\w+-helper-text\z/)
      expect(fieldset["aria-describedby"]).to eq("#{helper[:id]} #{message[:id]}")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:title) }.to raise_error(ArgumentError, /needs `form:`/)
    end
  end
end
