# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::FileInput, type: :component do
  # Flowbite's "File input" example, the default file input
  flowbite_file_input = "block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer " \
                        "bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 " \
                        "dark:placeholder-gray-400"

  def file_input
    page.find("input[type='file']")
  end

  def file_input_classes
    class_set(file_input[:class])
  end

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(file_input_classes).to eq(class_set(flowbite_file_input))
    end

    it "carries the classes of the small and large sizes" do
      render_inline(described_class.new(size: :sm))
      expect(file_input_classes).to include("text-xs")
      expect(file_input_classes).not_to include("text-sm")

      render_inline(described_class.new(size: :lg))
      expect(file_input_classes).to include("text-lg")
      expect(file_input_classes).not_to include("text-sm")
    end

    it "carries the input field's colors for the success and error state" do
      render_inline(described_class.new(validation: :success))
      expect(file_input_classes).to include("bg-green-50", "border-green-500", "text-green-900", "dark:border-green-500")
      expect(file_input_classes).not_to include("bg-gray-50", "border-gray-300")

      render_inline(described_class.new(validation: :error))
      expect(file_input_classes).to include("bg-red-50", "border-red-500", "text-red-900", "dark:border-red-500")
      expect(file_input_classes).not_to include("bg-gray-50", "border-gray-300")
    end

    it "takes the disabled look: a not-allowed cursor, no pointer, and the disabled background" do
      render_inline(described_class.new(disabled: true))

      expect(file_input[:disabled]).to be_present
      expect(file_input_classes).to include("cursor-not-allowed", "bg-gray-100")
      expect(file_input_classes).not_to include("cursor-pointer", "bg-gray-50")
    end

    it "keeps the disabled cursor in the validation states" do
      render_inline(described_class.new(disabled: true, validation: :error))

      expect(file_input_classes).to include("cursor-not-allowed", "bg-red-50")
      expect(file_input_classes).not_to include("cursor-pointer")
    end

    it "doesn't look disabled for required" do
      render_inline(described_class.new(required: true))

      expect(file_input_classes).to eq(class_set(flowbite_file_input))
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "mx-4 bg-white p-8"))

      expect(file_input_classes).to include("mx-4", "bg-white", "p-8")
      expect(file_input_classes).not_to include("bg-gray-50")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only" do
      render_inline(described_class.new(validation: :error))
      expect(file_input["aria-invalid"]).to eq("true")

      render_inline(described_class.new(validation: :success))
      expect(file_input["aria-invalid"]).to be_nil
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(file_input["aria-invalid"]).to eq("false")
    end
  end

  describe "without a form" do
    it "renders a plain file input with HTML attributes" do
      render_inline(described_class.new(name: "avatar", id: "avatar", multiple: true, accept: "image/*",
                                        required: true, aria: { label: "Avatar" }))

      expect(page).to have_css("input[type='file'][name='avatar'][id='avatar'][multiple][accept='image/*']")
      expect(file_input[:required]).to be_present
      expect(file_input["aria-label"]).to eq("Avatar")
      expect(page).to have_no_css("div")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:avatar) }.to raise_error(ArgumentError, /Gustwave::Form::FileInput needs `form:`/)
    end
  end

  describe "with a form" do
    it "renders name and id as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task)))

      expect(file_input[:type]).to eq("file")
      expect(file_input[:name]).to eq("task[title]")
      expect(file_input[:id]).to eq("task_title")
    end

    it "names a multiple file input as a list" do
      render_inline(described_class.new(:title, form: form_builder, multiple: true))

      expect(file_input[:name]).to eq("task[title][]")
      expect(file_input[:multiple]).to be_present
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:title, form: form_builder, id: "my-file", name: "my[file]"))

      expect(file_input[:id]).to eq("my-file")
      expect(file_input[:name]).to eq("my[file]")
    end

    it "renders through Gustwave::FormBuilder's own form as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task, builder: Gustwave::FormBuilder)))

      expect(page).to have_css("input[type='file']#task_title[name='task[title]']")
      expect(page).to have_no_css("label")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:title, form: form_builder(index: 3, namespace: "ns")))

      expect(file_input[:name]).to eq("task[3][title]")
      expect(file_input[:id]).to eq("ns_task_3_title")
    end

    it "never wraps the file input in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      form = form_builder(invalid_task)

      expect(form.file_field(:title)).to include("field_with_errors")

      render_inline(described_class.new(:title, form:, validation: :error))

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("input[type='file']#task_title[aria-invalid='true']")
    ensure
      ActionView::Base.field_error_proc = original
    end

    it "sets the form's multipart encoding, on the form the caller passed" do
      form = form_builder
      expect(form.multipart?).to be_falsey

      render_inline(described_class.new(:title, form:))

      expect(form.multipart?).to be(true)
    end

    it "leaves the form's encoding alone without a bound attribute" do
      form = form_builder
      render_inline(described_class.new(form: form))

      expect(form.multipart?).to be_falsey
    end
  end

  describe "#apply_slot_context" do
    it "binds the file input to the context's form and attribute" do
      component = described_class.new
      component.apply_slot_context(form: form_builder, attribute: :title)
      render_inline(component)

      expect(file_input[:name]).to eq("task[title]")
    end

    it "keeps the file input's own form and attribute" do
      component = described_class.new(:title, form: form_builder(name: :own))
      component.apply_slot_context(form: form_builder(name: :other), attribute: :password)
      render_inline(component)

      expect(file_input[:name]).to eq("own[title]")
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(file_input["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(file_input["aria-invalid"]).to be_nil
      expect(file_input_classes).to include("bg-green-50")
    end

    it "takes the ID of a file input without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(file_input[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(file_input[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(file_input["aria-describedby"]).to eq("hint helper other")
    end

    it "ignores keys it doesn't know" do
      expect { described_class.new.apply_slot_context(slot: :control, other: 1) }.not_to raise_error
    end
  end

  describe "#html_id" do
    it "is the caller's ID, the context's ID or Rails' ID for the attribute" do
      expect(described_class.new(id: "own").html_id).to eq("own")
      expect(described_class.new(:title, form: form_builder).html_id).to eq("task_title")
      expect(described_class.new.html_id).to be_nil

      component = described_class.new
      component.apply_slot_context(id: "ctx")
      expect(component.html_id).to eq("ctx")
    end
  end
end
