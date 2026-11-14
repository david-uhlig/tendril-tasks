# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::InlineField, type: :component do
  def toggle
    page.find("input[type='checkbox']", visible: :all)
  end

  def radio_input
    page.find("input[type='radio']", visible: :all)
  end

  def label
    page.find("label[for]")
  end

  def classes_of(node)
    class_set(node[:class])
  end

  def render_field(*args, **kwargs, &block)
    render_inline(described_class.new(*args, **kwargs)) do |field|
      field.with_control_toggle unless block
      block&.call(field)
    end
  end

  describe "markup" do
    it "renders a div without classes, with the caller's attributes" do
      render_field(:title, form: form_builder, class: "mb-6", data: { x: 1 })

      root = page.find("div", match: :first)
      expect(root[:class]).to eq("mb-6")
      expect(root["data-x"]).to eq("1")
    end

    it "renders the control beside a column with the label and the helper text, as Flowbite's checkbox with helper text" do
      render_field(:title, form: form_builder, label: "Notify", helper_text: "Help")

      row = page.find("div > div", match: :first)
      expect(classes_of(row)).to eq(class_set("flex"))
      cell, text = row.all(:xpath, "./div").to_a
      expect(classes_of(cell)).to eq(class_set("flex items-center"))
      expect(cell).to have_css("label > input[type='checkbox']", visible: :all)
      expect(text.all(:xpath, "./*").map(&:tag_name)).to eq(%w[label p])
      expect(classes_of(label)).to eq(class_set("font-medium text-gray-900 dark:text-gray-300"))
      expect(classes_of(text.find("p"))).to eq(class_set("text-xs font-normal text-gray-500 dark:text-gray-300"))
    end

    it "renders the validation message below the row" do
      render_field(:title, form: form_builder, validation: :error, validation_message: "Message")

      expect(page.all("body > div > *").map(&:tag_name)).to eq(%w[div p])
      expect(classes_of(page.find("p"))).to eq(class_set("mt-2 text-sm text-red-600 dark:text-red-500"))
      expect(classes_of(label)).to include("text-red-700", "dark:text-red-500")
    end

    it "renders no text column without a label and helper text" do
      render_field(label: false) { |field| field.with_control_toggle(aria: { label: "Notify" }) }

      expect(page).to have_css("div.flex > div", count: 1)
      expect(page).to have_css("label", count: 1)
    end

    it "takes the block as the control without a control slot" do
      render_inline(described_class.new(label: "Remember me")) { "<input type=\"checkbox\" id=\"own\">".html_safe }

      expect(page).to have_css("div.flex > div.items-center > input#own")
      expect(page).to have_css("div.flex > div + div > label", text: "Remember me")
    end

    it "styles the row, the control cell and the text column with their options" do
      render_field(label: "Notify", row_options: { class: "gap-1" }, control_cell_options: { class: "h-5" },
                   text_options: { class: "ms-4", data: { a: "1" } })

      expect(classes_of(page.find("div.flex.gap-1"))).to include("flex")
      expect(page).to have_css("div.flex > div.h-5.items-center")
      text = page.find("div[data-a='1']")
      expect(classes_of(text)).to include("ms-4", "text-sm")
      expect(classes_of(text)).not_to include("ms-3")
    end
  end

  describe "the gap between the control and the text" do
    it "is Flowbite's ms-3 after a toggle" do
      render_field(label: "Notify")

      expect(classes_of(page.find("div.flex > div + div"))).to eq(class_set("ms-3 text-sm"))
    end

    it "is Flowbite's ms-2 after any other control" do
      render_inline(described_class.new(label: "Remember me")) { "<input type=\"checkbox\">".html_safe }

      expect(classes_of(page.find("div.flex > div + div"))).to eq(class_set("ms-2 text-sm"))
    end

    it "is ms-2 after a renderable control" do
      render_field(label: "Notify") { |field| field.with_control_renderable(Gustwave::Form::Toggle.new) }

      expect(classes_of(page.find("div.flex > div + div"))).to eq(class_set("ms-2 text-sm"))
    end

    it "is Flowbite's ms-2 after a checkbox" do
      render_field(label: "Remember me") { |field| field.with_control_checkbox }

      expect(classes_of(page.find("div.flex > div + div"))).to eq(class_set("ms-2 text-sm"))
    end
  end

  describe "with a checkbox" do
    it "renders Flowbite's checkbox with helper text: the box in a cell of the label's line height" do
      render_field(label: "Remember me", helper_text: "For 30 days.") { |field| field.with_control_checkbox(color: :green) }

      cell, text = page.find("div.flex", match: :first).all(:xpath, "./div").to_a
      expect(classes_of(cell)).to eq(class_set("flex items-center h-5"))
      expect(cell.all(:xpath, "./*").map(&:tag_name)).to eq(%w[input])
      expect(classes_of(cell.find("input"))).to include("w-4", "h-4", "text-green-600")
      expect(classes_of(text)).to eq(class_set("ms-2 text-sm"))
      expect(text.all(:xpath, "./*").map(&:tag_name)).to eq(%w[label p])
      expect(page).to have_css("label", count: 1)
    end

    it "keeps the cell of any other control without a height" do
      render_field(label: "Notify")
      expect(classes_of(page.find("div.flex > div", match: :first))).to eq(class_set("flex items-center"))

      render_field(label: "Notify") { |field| field.with_control_renderable(Gustwave::Form::Checkbox.new) }
      expect(classes_of(page.find("div.flex > div", match: :first))).to eq(class_set("flex items-center"))
    end

    it "lets the caller's cell classes win over the height" do
      render_field(label: "Remember me", control_cell_options: { class: "h-6" }) { |field| field.with_control_checkbox }

      expect(classes_of(page.find("div.flex > div", match: :first))).to eq(class_set("flex items-center h-6"))
    end

    it "binds the checkbox, with the label's for matching its id and the hidden field beside it" do
      render_field(:title, form: form_builder, helper_text: "Help") { |field| field.with_control_checkbox }

      expect(label[:for]).to eq("task_title")
      expect(toggle[:id]).to eq("task_title")
      expect(toggle[:name]).to eq("task[title]")
      expect(toggle["aria-describedby"]).to eq("task_title_helper_text")
      expect(page).to have_css("div.h-5 > input[type='hidden'][name='task[title]'][value='0']", visible: :all)
    end

    it "wires an unbound checkbox with a generated ID" do
      render_field(label: "Remember me") { |field| field.with_control(:checkbox, value: "1") }

      expect(toggle[:id]).to start_with("field-")
      expect(label[:for]).to eq(toggle[:id])
    end

    it "points the label at the ID of a multiple checkbox, which carries the checked value" do
      render_field(:title, form: form_builder) do |field|
        field.with_control_checkbox(multiple: true, checked_value: "a", unchecked_value: nil)
      end

      expect(toggle[:id]).to eq("task_title_a")
      expect(label[:for]).to eq("task_title_a")
    end

    it "passes the error state on and grays the label of a disabled checkbox" do
      render_field(:title, form: form_builder(invalid_task)) { |field| field.with_control_checkbox(disabled: true) }

      expect(toggle["aria-invalid"]).to eq("true")
      expect(page).to have_css("p#task_title_validation_message", text: "Can't be blank")
      expect(classes_of(label)).to eq(class_set("font-medium text-gray-400 dark:text-gray-500"))
    end
  end

  describe "with a radio" do
    it "renders the radio in a cell of the label's line height, like the checkbox" do
      render_field(label: "Free", helper_text: "No card needed.") { |field| field.with_control_radio(color: :green, value: "free") }

      cell, text = page.find("div.flex", match: :first).all(:xpath, "./div").to_a
      expect(classes_of(cell)).to eq(class_set("flex items-center h-5"))
      expect(cell.all(:xpath, "./*").map(&:tag_name)).to eq(%w[input])
      expect(cell.find("input")[:type]).to eq("radio")
      expect(classes_of(cell.find("input"))).to include("w-4", "h-4", "text-green-600")
      expect(classes_of(text)).to eq(class_set("ms-2 text-sm"))
      expect(text.all(:xpath, "./*").map(&:tag_name)).to eq(%w[label p])
    end

    it "binds the radio, with the label's for matching its id, and labels it by its value" do
      render_field(:title, form: form_builder, helper_text: "Help") { |field| field.with_control_radio(value: "free") }

      expect(label.text).to eq("Free")
      expect(label[:for]).to eq("task_title_free")
      expect(radio_input[:id]).to eq("task_title_free")
      expect(radio_input[:name]).to eq("task[title]")
      expect(radio_input["aria-describedby"]).to eq("task_title_free_helper_text")
      expect(page).to have_css("p#task_title_free_helper_text", text: "Help")
    end

    it "gives the radios of one attribute their own label for and text IDs" do
      render_inline(Gustwave::Form::InlineField.new(:title, form: form_builder, helper_text: "One", validation: :error, validation_message: "Wrong")) do |field|
        field.with_control_radio(value: "free")
      end
      first = page.native.to_html
      render_inline(Gustwave::Form::InlineField.new(:title, form: form_builder, helper_text: "Two", validation: :error, validation_message: "Wrong")) do |field|
        field.with_control_radio(value: "pro")
      end
      second = page.native.to_html

      expect(first).to include('for="task_title_free"', 'id="task_title_free_helper_text"', 'id="task_title_free_validation_message"')
      expect(second).to include('for="task_title_pro"', 'id="task_title_pro_helper_text"', 'id="task_title_pro_validation_message"')
      expect(radio_input["aria-describedby"]).to eq("task_title_pro_helper_text task_title_pro_validation_message")
    end

    it "keeps the IDs of the texts of a control whose ID doesn't extend Rails' ID" do
      render_field(:title, form: form_builder, helper_text: "Help") { |field| field.with_control_radio(value: "free", id: "mine") }

      expect(radio_input["aria-describedby"]).to eq("task_title_helper_text")
    end

    it "labels a radio by the translation or the humanized value" do
      render_field(:title, form: form_builder) { |field| field.with_control_radio(value: "in_progress") }

      expect(label.text).to eq("In progress")
    end

    it "labels a radio by the translation for its value" do
      I18n.backend.store_translations(:en, helpers: { label: { task: { title: { free: "Free of charge" } } } })
      render_field(:title, form: form_builder) { |field| field.with_control_radio(value: "free") }

      expect(label.text).to eq("Free of charge")
    ensure
      I18n.backend.reload!
    end

    it "labels a radio by the humanized value in a form without an object" do
      render_field(:title, form: form_builder(nil)) { |field| field.with_control_radio(value: "free") }

      expect(label.text).to eq("Free")
    end

    it "labels a radio whose value is false by the humanized value" do
      render_field(:title, form: form_builder) { |field| field.with_control_radio(value: false) }

      expect(label.text).to eq("False")
    end

    it "points the label and the texts at a radio whose value is nil" do
      render_field(:title, form: form_builder, helper_text: "Help") { |field| field.with_control_radio(value: nil) }

      expect(radio_input[:id]).to eq("task_title")
      expect(label[:for]).to eq(radio_input[:id])
      expect(radio_input["aria-describedby"]).to eq("task_title_helper_text")
    end

    it "renders no validation message for validation_message: false, and keeps the state" do
      render_field(:title, form: form_builder(invalid_task), validation_message: false) { |field| field.with_control_radio(value: "free") }

      expect(page).to have_no_css("p")
      expect(radio_input["aria-invalid"]).to eq("true")
      expect(radio_input["aria-describedby"]).to be_nil
      expect(classes_of(label)).to include("text-red-700")
    end

    it "wires an unbound radio with a generated ID" do
      render_field(label: "Free") { |field| field.with_control(:radio, value: "free") }

      expect(radio_input[:id]).to start_with("field-")
      expect(label[:for]).to eq(radio_input[:id])
    end
  end

  describe "the wiring" do
    it "binds a toggle to the attribute, with the label's for matching its id" do
      render_field(:title, form: form_builder, helper_text: "Help") { |field| field.with_control_toggle(color: :green) }

      expect(label.text).to eq("Title")
      expect(label[:for]).to eq("task_title")
      expect(toggle[:id]).to eq("task_title")
      expect(toggle[:name]).to eq("task[title]")
      expect(toggle["aria-describedby"]).to eq("task_title_helper_text")
      expect(page).to have_css("p#task_title_helper_text", text: "Help")
    end

    it "never nests the field's label in the toggle's" do
      render_field(:title, form: form_builder)

      expect(page).to have_no_css("label label")
      expect(page).to have_css("label", count: 2)
      expect(page.find("label:not([for])")).to have_css("input#task_title", visible: :all)
    end

    it "passes the error state on and shows the attribute's errors" do
      render_field(:title, form: form_builder(invalid_task))

      expect(toggle["aria-invalid"]).to eq("true")
      expect(toggle["aria-describedby"]).to eq("task_title_validation_message")
      expect(page).to have_css("p#task_title_validation_message", text: "Can't be blank")
      expect(page).to have_no_css(".field_with_errors")
    end

    it "wires an unbound toggle with a generated ID" do
      render_field(label: "Notify", helper_text: "Help") { |field| field.with_control(:toggle, value: "1") }

      expect(toggle[:id]).to start_with("field-")
      expect(label[:for]).to eq(toggle[:id])
      expect(toggle["aria-describedby"]).to eq("#{toggle[:id]}-helper-text")
    end

    it "grays the label of a disabled control, as Flowbite's disabled toggle" do
      render_field(label: "Sync") { |field| field.with_control_toggle(disabled: true) }

      expect(classes_of(label)).to eq(class_set("font-medium text-gray-400 dark:text-gray-500"))
    end

    it "grays the label of a disabled control in the error state, too" do
      render_field(label: "Sync", validation: :error) { |field| field.with_control_toggle(disabled: true) }

      expect(classes_of(label)).to eq(class_set("font-medium text-gray-400 dark:text-gray-500"))
    end

    it "grays the label for a disabled renderable control" do
      render_field(label: "Sync") { |field| field.with_control_renderable(Gustwave::Form::Toggle.new(disabled: true)) }

      expect(classes_of(label)).to include("text-gray-400", "dark:text-gray-500")
    end

    it "keeps the label's colors for an enabled or required control" do
      render_field(label: "Sync") { |field| field.with_control_toggle(required: true) }

      expect(classes_of(label)).to eq(class_set("font-medium text-gray-900 dark:text-gray-300"))
    end

    it "lets the label's own classes win over the gray" do
      render_field do |field|
        field.with_control_toggle(disabled: true)
        field.with_label("Sync", class: "text-gray-900 dark:text-gray-300")
      end

      expect(classes_of(label)).to eq(class_set("font-medium text-gray-900 dark:text-gray-300"))
    end

    it "leaves the gray to the caller with a block as the control" do
      render_inline(described_class.new) do |field|
        field.with_label("Sync", class: "text-gray-400 dark:text-gray-500")
        "<input type=\"checkbox\" disabled>".html_safe
      end

      expect(classes_of(page.find("label"))).to eq(class_set("font-medium text-gray-400 dark:text-gray-500"))
    end

    it "raises for an attribute without a form, naming the class" do
      expect { described_class.new(:title) }.to raise_error(ArgumentError, /Gustwave::Form::InlineField needs `form:`/)
    end

    it "has no control types of the stacked field" do
      expect(described_class.new).not_to respond_to(:with_control_input)
      expect(Gustwave::Form::Field.new).not_to respond_to(:with_control_toggle)
    end
  end
end
