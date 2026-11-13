# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Field, type: :component do
  def input
    page.find("input")
  end

  def label
    page.find("label")
  end

  def classes_of(node)
    class_set(node[:class])
  end

  def render_field(*args, **kwargs, &block)
    render_inline(described_class.new(*args, **kwargs)) do |field|
      field.with_control_input unless block
      block&.call(field)
    end
  end

  it "renders a div without classes, with the caller's attributes" do
    render_field(:title, form: form_builder, class: "mb-6", data: { x: 1 })

    root = page.find("div")
    expect(root[:class]).to eq("mb-6")
    expect(root["data-x"]).to eq("1")
  end

  it "renders the label, control, helper text and message in that order" do
    render_field(:title, form: form_builder, helper_text: "Help", validation_message: "Message")

    expect(page.all("div > *").map(&:tag_name)).to eq(%w[label input p p])
  end

  describe "the label" do
    it "defaults to the text of Rails' label helper, for the control's id" do
      render_field(:due_on, form: form_builder) { |f| f.with_control_input(type: :date) }

      expect(label.text).to eq("Due on")
      expect(label[:for]).to eq("task_due_on")
      expect(input[:id]).to eq("task_due_on")
      expect(classes_of(label)).to eq(class_set("block mb-2 text-sm font-medium text-gray-900 dark:text-white"))
    end

    it "uses Rails' translation" do
      I18n.backend.store_translations(:en, helpers: { label: { task: { title: "Name of the task" } } })
      render_field(:title, form: form_builder)

      expect(label.text).to eq("Name of the task")
    ensure
      I18n.backend.reload!
    end

    it "renders no label for false or nil" do
      render_field(:title, form: form_builder, label: false)
      expect(page).to have_no_css("label")

      render_field(:title, form: form_builder, label: nil)
      expect(page).to have_no_css("label")
    end

    it "takes text" do
      render_field(:title, form: form_builder, label: "Task title")

      expect(label.text).to eq("Task title")
    end

    it "takes the slot with text and options" do
      render_field(:title, form: form_builder) do |field|
        field.with_label("Task title", class: "sr-only")
        field.with_control_input
      end

      expect(label.text).to eq("Task title")
      expect(classes_of(label)).to include("sr-only")
    end

    it "takes a block" do
      render_field(:title, form: form_builder) do |field|
        field.with_label { "Task <b>title</b>".html_safe }
        field.with_control_input
      end

      expect(page).to have_css("label b", text: "title")
    end

    it "wins over the keyword when both are given" do
      render_field(:title, form: form_builder, label: "Keyword") do |field|
        field.with_label("Slot")
        field.with_control_input
      end

      expect(page.all("label").map(&:text)).to eq([ "Slot" ])
    end

    it "follows the control's own id" do
      render_field(:title, form: form_builder) { |f| f.with_control_input(id: "custom") }

      expect(label[:for]).to eq("custom")
      expect(input[:id]).to eq("custom")
    end

    it "isn't wrapped by field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      form = form_builder(invalid_task)

      expect(form.label(:title)).to include("field_with_errors")

      render_field(:title, form:)

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("label[for='task_title']")
    ensure
      ActionView::Base.field_error_proc = original
    end

    it "renders only what the caller sets without a form" do
      render_field(label: "Name")

      expect(label.text).to eq("Name")
      expect(label[:for]).to be_present
      expect(label[:for]).to eq(input[:id])

      render_field
      expect(page).to have_no_css("label")
    end
  end

  describe "helper text and validation message" do
    it "takes text or a block" do
      render_field(:title, form: form_builder, helper_text: "Shown in the list.") do |field|
        field.with_validation_message { "<span class='font-medium'>Oh, snapp!</span> Some message.".html_safe }
        field.with_control_input
      end

      expect(page).to have_css("p#task_title_helper_text", text: "Shown in the list.")
      expect(page).to have_css("p#task_title_validation_message span.font-medium", text: "Oh, snapp!")
    end

    it "renders the helper text with a link from a block" do
      render_field(:title, form: form_builder) do |field|
        field.with_helper_text { "Read our #{ActionController::Base.helpers.link_to("rules", "#")}.".html_safe }
        field.with_control_input
      end

      expect(page).to have_css("p a", text: "rules")
    end

    it "carries Flowbite's classes for the helper text" do
      render_field(:title, form: form_builder, helper_text: "Help")

      expect(classes_of(page.find("p"))).to eq(class_set("mt-2 text-sm text-gray-500 dark:text-gray-400"))
    end

    it "gives a validation message the helper text's look without a state" do
      render_field(:title, form: form_builder, validation_message: "Info")

      expect(classes_of(page.find("p"))).to eq(class_set("mt-2 text-sm text-gray-500 dark:text-gray-400"))
    end

    it "colors label and message per state like Flowbite" do
      render_field(:title, form: form_builder, validation: :success, validation_message: "Well done!")

      expect(classes_of(label)).to eq(class_set("block mb-2 text-sm font-medium text-green-700 dark:text-green-500"))
      expect(classes_of(page.find("p"))).to eq(class_set("mt-2 text-sm text-green-600 dark:text-green-500"))
      expect(input[:class]).to include("bg-green-50")

      render_field(:title, form: form_builder, validation: :error, validation_message: "Oh, snapp!")

      expect(classes_of(label)).to eq(class_set("block mb-2 text-sm font-medium text-red-700 dark:text-red-500"))
      expect(classes_of(page.find("p"))).to eq(class_set("mt-2 text-sm text-red-600 dark:text-red-500"))
      expect(input[:class]).to include("bg-red-50")
    end
  end

  describe "validation state" do
    it "is none without errors" do
      render_field(:title, form: form_builder(task(title: "x")))

      expect(input["aria-invalid"]).to be_nil
      expect(input[:class]).to include("bg-gray-50")
    end

    it "is error while the attribute has errors" do
      render_field(:title, form: form_builder(invalid_task))

      expect(input["aria-invalid"]).to eq("true")
      expect(input[:class]).to include("bg-red-50")
      expect(classes_of(label)).to include("text-red-700")
    end

    it "takes the errors of the association of a name_id attribute" do
      record = task
      record.errors.add(:project, "must exist")
      render_field(:project_id, form: form_builder(record)) { |f| f.with_control_input(type: :number) }

      expect(input["aria-invalid"]).to eq("true")
      expect(page).to have_css("p", text: "Must exist")
    end

    it "ignores the errors of other attributes" do
      record = task
      record.errors.add(:password, "is too short")
      render_field(:title, form: form_builder(record))

      expect(input["aria-invalid"]).to be_nil
    end

    it "lets the caller's validation win" do
      render_field(:title, form: form_builder(invalid_task), validation: :success)

      expect(input["aria-invalid"]).to be_nil
      expect(input[:class]).to include("bg-green-50")
    end

    it "lets the control's own validation win" do
      render_field(:title, form: form_builder(invalid_task)) { |f| f.with_control_input(validation: :success) }

      expect(input[:class]).to include("bg-green-50")
      expect(classes_of(label)).to include("text-red-700")
    end

    it "copes with a builder without an object and an object without errors" do
      render_field(:title, form: form_builder(nil))
      expect(input["aria-invalid"]).to be_nil

      render_field(:title, form: form_builder(Struct.new(:title).new("x")))
      expect(input["aria-invalid"]).to be_nil
    end
  end

  describe "the default validation message" do
    it "lists the attribute's errors as a sentence" do
      record = task
      record.errors.add(:title, "can't be blank")
      record.errors.add(:title, "is too short")
      render_field(:title, form: form_builder(record))

      expect(page.find("p").text).to eq("Can't be blank and is too short")
    end

    it "yields to the caller's message" do
      render_field(:title, form: form_builder(invalid_task), validation_message: "Pick a title.")

      expect(page.all("p").map(&:text)).to eq([ "Pick a title." ])
    end

    it "renders nothing without errors" do
      render_field(:title, form: form_builder)

      expect(page).to have_no_css("p")
    end

    it "renders nothing for an unbound field" do
      render_field(validation: :error)

      expect(page).to have_no_css("p")
    end
  end

  describe "aria-describedby" do
    it "lists the helper text and the message that are rendered" do
      render_field(:title, form: form_builder, helper_text: "Help", validation_message: "Message")

      expect(input["aria-describedby"]).to eq("task_title_helper_text task_title_validation_message")
    end

    it "lists only the helper text" do
      render_field(:title, form: form_builder, helper_text: "Help")

      expect(input["aria-describedby"]).to eq("task_title_helper_text")
    end

    it "lists the error message of a bound field" do
      render_field(:title, form: form_builder(invalid_task))

      expect(input["aria-describedby"]).to eq("task_title_validation_message")
      expect(page).to have_css("p#task_title_validation_message")
    end

    it "is absent without either" do
      render_field(:title, form: form_builder)

      expect(input["aria-describedby"]).to be_nil
    end

    it "merges with the caller's" do
      render_field(:title, form: form_builder, helper_text: "Help") do |field|
        field.with_control_input(aria: { describedby: "hint" })
      end

      expect(input["aria-describedby"]).to eq("hint task_title_helper_text")
    end
  end

  describe "a textarea control" do
    def textarea
      page.find("textarea")
    end

    def textarea_text
      textarea.text.delete_prefix("\n")
    end

    it "wires a bound textarea: label for, aria-describedby and the text from the record" do
      render_field(:title, form: form_builder(task(title: "Write")), helper_text: "Help") do |field|
        field.with_control_textarea(rows: 4)
      end

      expect(label[:for]).to eq("task_title")
      expect(textarea[:id]).to eq("task_title")
      expect(textarea[:rows]).to eq("4")
      expect(textarea_text).to eq("Write")
      expect(textarea["aria-describedby"]).to eq("task_title_helper_text")
    end

    it "passes the error state on" do
      render_field(:title, form: form_builder(invalid_task)) { |field| field.with_control_textarea }

      expect(textarea["aria-invalid"]).to eq("true")
      expect(class_set(textarea[:class])).to include("bg-red-50")
      expect(textarea["aria-describedby"]).to eq("task_title_validation_message")
    end

    it "wires an unbound textarea with a generated ID" do
      render_field(label: "Message", helper_text: "Help") { |field| field.with_control(:textarea, rows: 2) }

      expect(textarea[:id]).to start_with("field-")
      expect(label[:for]).to eq(textarea[:id])
      expect(textarea["aria-describedby"]).to eq("#{textarea[:id]}-helper-text")
    end
  end

  describe "ids" do
    it "differ between forms with another namespace or object name" do
      render_inline(described_class.new(:title, form: form_builder(namespace: "a"), helper_text: "Help")) { |f| f.with_control_input }
      first = page.native.to_html
      render_inline(described_class.new(:title, form: form_builder(name: :project, namespace: "b"), helper_text: "Help")) { |f| f.with_control_input }

      expect(first).to include('id="a_task_title"', "a_task_title_helper_text")
      expect(page).to have_css("input#b_project_title[aria-describedby='b_project_title_helper_text']")
      expect(page).to have_css("label[for='b_project_title']")
    end

    it "are generated for a field without a form, and derived from the control's" do
      render_field(label: "Name", helper_text: "Help", validation_message: "Message")

      id = input[:id]
      expect(id).to start_with("field-")
      expect(label[:for]).to eq(id)
      expect(input["aria-describedby"]).to eq("#{id}-helper-text #{id}-validation-message")
      expect(page).to have_css("p##{id}-helper-text")
      expect(page).to have_css("p##{id}-validation-message")
    end

    it "follow the control's own id without a form" do
      render_field(label: "Name", helper_text: "Help") { |f| f.with_control_input(id: "name") }

      expect(label[:for]).to eq("name")
      expect(input["aria-describedby"]).to eq("name-helper-text")
    end
  end

  describe "the control" do
    it "binds the input to the form and attribute" do
      render_field(:title, form: form_builder(task(title: "Write")))

      expect(input[:name]).to eq("task[title]")
      expect(input[:value]).to eq("Write")
    end

    it "passes the input's options" do
      render_field(:title, form: form_builder) { |f| f.with_control_input(type: :email, size: :lg, icon: :envelope) }

      expect(input[:type]).to eq("email")
      expect(page).to have_css("div.relative svg")
      expect(classes_of(input)).to include("p-4", "ps-10")
    end

    it "renders the block in place of a control" do
      render_inline(described_class.new(label: "Plan", helper_text: "Pick one.")) do
        "<select id='plan'></select>".html_safe
      end

      expect(page.all("div > *").map(&:tag_name)).to eq(%w[label select p])
    end

    it "gives a renderable control the context" do
      received = nil
      custom = stub_const("ContextSpyControl", Class.new(Gustwave::Component) do
        define_method(:apply_slot_context) { |**context| received = context }
        define_method(:call) { tag.span("custom") }
      end)

      render_inline(described_class.new(:title, form: form_builder(invalid_task), helper_text: "Help")) do |field|
        field.with_control_renderable(custom.new)
      end

      expect(received).to include(attribute: :title, validation: :error, described_by: "task_title_helper_text task_title_validation_message",
                                  slot: :control)
      expect(received[:form]).to be_a(ActionView::Helpers::FormBuilder)
      expect(page).to have_css("span", text: "custom")
    end

    it "renders a renderable control that takes no context" do
      custom = stub_const("PlainControl", Class.new(Gustwave::Component) { define_method(:call) { tag.span("plain") } })

      render_inline(described_class.new(label: "Plan")) { |field| field.with_control_renderable(custom.new) }

      expect(page).to have_css("label", text: "Plan")
      expect(page).to have_css("span", text: "plain")
    end
  end

  it "raises for an attribute without a form" do
    expect { described_class.new(:title) }.to raise_error(ArgumentError, /form:/)
  end
end
