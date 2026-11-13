# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Textarea, type: :component do
  helpers = FormSpecHelpers

  def textarea
    page.find("textarea")
  end

  # The text without the newline Rails adds after the opening tag
  def textarea_text
    textarea.text.delete_prefix("\n")
  end

  def textarea_classes
    class_set(textarea[:class])
  end

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_TEXTAREA))
    end

    it "carries the input field's classes for the success and error state" do
      render_inline(described_class.new(validation: :success))
      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_INPUT_SUCCESS))

      render_inline(described_class.new(validation: :error))
      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_INPUT_ERROR))
    end

    it "carries the input field's classes for the disabled state" do
      render_inline(described_class.new(disabled: true))

      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_INPUT_DISABLED))
      expect(textarea[:disabled]).to be_present
    end

    it "doesn't look disabled for readonly or required" do
      render_inline(described_class.new(readonly: true, required: true))

      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_TEXTAREA))
    end

    it "keeps the disabled cursor in the validation states" do
      render_inline(described_class.new(disabled: true, validation: :error))

      expect(textarea_classes).to include("cursor-not-allowed", "bg-red-50")
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "mx-4 bg-white p-8"))

      expect(textarea_classes).to include("mx-4", "bg-white", "p-8")
      expect(textarea_classes).not_to include("bg-gray-50", "p-2.5")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only" do
      render_inline(described_class.new(validation: :error))
      expect(textarea["aria-invalid"]).to eq("true")

      render_inline(described_class.new(validation: :success))
      expect(textarea["aria-invalid"]).to be_nil
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(textarea["aria-invalid"]).to eq("false")
    end
  end

  describe "without a form" do
    it "renders a plain textarea with HTML attributes" do
      render_inline(described_class.new(name: "message", id: "msg", rows: 4, placeholder: "Write", maxlength: 200,
                                        required: true, aria: { label: "Message" }))

      expect(page).to have_css("textarea#msg[name='message'][rows='4'][placeholder='Write'][maxlength='200']")
      expect(textarea[:required]).to be_present
      expect(textarea["aria-label"]).to eq("Message")
      expect(page).to have_no_css("div")
    end

    it "renders the value option as text, not as an attribute" do
      render_inline(described_class.new(value: "Hello <b>"))

      expect(textarea_text).to eq("Hello <b>")
      expect(textarea.native["value"]).to be_nil
      expect(page).to have_no_css("b")
    end

    it "renders the block as text" do
      render_inline(described_class.new) { "From the block" }

      expect(textarea_text).to eq("From the block")
    end

    it "prefers the value option to the block" do
      render_inline(described_class.new(value: "Option")) { "Block" }

      expect(textarea_text).to eq("Option")
    end

    it "renders Rails' leading newline once" do
      render_inline(described_class.new(value: "Hello"))

      expect(page.native.to_html).to include(">\nHello</textarea>")
      expect(page.native.to_html).not_to include(">\n\nHello")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:notes) }.to raise_error(ArgumentError, /Gustwave::Form::Textarea needs `form:`/)
    end
  end

  describe "with a form" do
    it "renders name, id and text as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "Write specs")), rows: 3))

      expect(textarea[:name]).to eq("task[title]")
      expect(textarea[:id]).to eq("task_title")
      expect(textarea[:rows]).to eq("3")
      expect(textarea_text).to eq("Write specs")
    end

    it "takes the text from a value option" do
      render_inline(described_class.new(:title, form: form_builder, value: "Given"))

      expect(textarea_text).to eq("Given")
    end

    it "renders through Gustwave::FormBuilder's own form as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "x"), builder: Gustwave::FormBuilder)))

      expect(page).to have_css("textarea#task_title[name='task[title]']", text: "x")
      expect(page).to have_no_css("label")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:title, form: form_builder(index: 3, namespace: "ns")))

      expect(textarea[:name]).to eq("task[3][title]")
      expect(textarea[:id]).to eq("ns_task_3_title")
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:title, form: form_builder, id: "my-title", name: "my[title]"))

      expect(textarea[:id]).to eq("my-title")
      expect(textarea[:name]).to eq("my[title]")
    end

    it "gives cols and rows for Rails' size option" do
      render_inline(described_class.new(:title, form: form_builder, size: "20x40"))

      expect(textarea[:cols]).to eq("20")
      expect(textarea[:rows]).to eq("40")
    end

    it "renders a builder for a url-only form" do
      render_inline(described_class.new(:title, form: form_builder(nil, name: nil)))

      expect(textarea[:name]).to eq("title")
    end

    it "never wraps the textarea in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      form = form_builder(invalid_task)

      expect(form.text_area(:title)).to include("field_with_errors")

      render_inline(described_class.new(:title, form:, validation: :error))

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("textarea#task_title[aria-invalid='true']")
    ensure
      ActionView::Base.field_error_proc = original
    end
  end

  describe "header and footer" do
    # The frame, the first <div> of the component
    def frame
      page.find("div", match: :first)
    end

    # The frame's children in order: the header bar, the body and the footer bar
    def frame_children
      frame.all(:xpath, "./*")
    end

    def button_markup
      "<button type=\"submit\">Post</button>".html_safe
    end

    # Renders the textarea with the given bars, each the markup of its slot
    def render_bars(header: nil, footer: nil, **options)
      render_inline(described_class.new(**options)) do |textarea|
        textarea.with_header { header } if header
        textarea.with_footer { footer } if footer
        nil
      end
    end

    it "renders a footer bar below the body, and the textarea in the body" do
      render_bars(footer: button_markup, value: "Hi")

      expect(class_set(frame[:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_FRAME))
      expect(frame_children.map(&:tag_name)).to eq(%w[div div])
      expect(class_set(frame_children[0][:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_BODY_ABOVE_FOOTER))
      expect(frame_children[0]).to have_css("textarea")
      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_TEXTAREA_FRAMED))
      expect(class_set(frame_children[1][:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_FOOTER))
      expect(frame_children[1]).to have_css("button", text: "Post")
    end

    it "renders a header bar above the body" do
      render_bars(header: "<span>Bold</span>".html_safe, value: "Hi")

      expect(frame_children.map(&:tag_name)).to eq(%w[div div])
      expect(class_set(frame_children[0][:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_HEADER))
      expect(frame_children[0]).to have_css("span", text: "Bold")
      expect(class_set(frame_children[1][:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_BODY_UNDER_HEADER))
      expect(frame_children[1]).to have_css("textarea")
    end

    it "renders the header, the body and the footer, with the body's corners square" do
      render_bars(header: "H", footer: "F", value: "Hi")

      expect(frame_children.map(&:tag_name)).to eq(%w[div div div])
      expect(frame_children[0].text).to eq("H")
      expect(frame_children[2].text).to eq("F")
      expect(class_set(frame_children[0][:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_HEADER))
      expect(class_set(frame_children[1][:class])).to eq(class_set("px-4 py-2 bg-white dark:bg-gray-800"))
      expect(class_set(frame_children[2][:class])).to eq(class_set(helpers::FLOWBITE_TEXTAREA_FOOTER))
    end

    it "renders the textarea alone, without the frame, without slots" do
      render_inline(described_class.new(value: "Hi"))

      expect(page).to have_no_css("div")
      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_TEXTAREA))
    end

    it "colors the frame's border by the validation state, and only sets aria-invalid on the textarea" do
      render_bars(footer: "F", validation: :error, value: "Hi")

      expect(class_set(frame[:class])).to include("border-red-500")
      expect(class_set(frame[:class])).not_to include("border-gray-200")
      expect(textarea["aria-invalid"]).to eq("true")
      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_TEXTAREA_FRAMED))

      render_bars(footer: "F", validation: :success, value: "Hi")

      expect(class_set(frame[:class])).to include("border-green-500")
      expect(textarea["aria-invalid"]).to be_nil
    end

    it "disables the textarea without extra classes" do
      render_bars(footer: "F", disabled: true, value: "Hi")

      expect(textarea["disabled"]).to be_present
      expect(textarea_classes).to eq(class_set(helpers::FLOWBITE_TEXTAREA_FRAMED))
    end

    it "puts the parts' attributes on their elements and keeps the textarea's own options on the textarea" do
      render_bars(header: "H", footer: "F", value: "Hi", id: "msg", name: "message", rows: 4, placeholder: "Write",
                  frame_options: { class: "mb-4", data: { test: "frame" } },
                  header_options: { data: { test: "header" } },
                  body_options: { data: { test: "body" } },
                  footer_options: { class: "gap-2", data: { test: "footer" } })

      expect(class_set(frame[:class])).to include("mb-4")
      expect(frame["data-test"]).to eq("frame")
      expect(frame_children[0]["data-test"]).to eq("header")
      expect(frame_children[1]["data-test"]).to eq("body")
      expect(frame_children[2]["data-test"]).to eq("footer")
      expect(class_set(frame_children[2][:class])).to include("gap-2")
      expect(textarea[:id]).to eq("msg")
      expect(textarea[:name]).to eq("message")
      expect(textarea[:rows]).to eq("4")
      expect(textarea[:placeholder]).to eq("Write")
      expect(frame["rows"]).to be_nil
    end

    it "takes the text from value, not from the block, which sets the slots" do
      render_inline(described_class.new(value: "Hi")) do |textarea|
        textarea.with_footer { "F" }
        "Block"
      end

      expect(textarea_text).to eq("Hi")
    end

    it "leaves the textarea empty without value, although the block renders whitespace" do
      render_inline(described_class.new) do |textarea|
        textarea.with_footer { "F" }
        "  "
      end

      expect(textarea_text).to be_empty
    end

    it "takes the text of a bound textarea from the record" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "Write specs")))) do |textarea|
        textarea.with_footer { "F" }
      end

      expect(textarea[:name]).to eq("task[title]")
      expect(textarea[:id]).to eq("task_title")
      expect(textarea_text).to eq("Write specs")
      expect(page).to have_css("div > div > textarea#task_title")
    end

    it "never wraps a framed bound textarea in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      form = form_builder(invalid_task)

      expect(form.text_area(:title)).to include("field_with_errors")

      render_inline(described_class.new(:title, form:, validation: :error)) do |textarea|
        textarea.with_footer { "F" }
      end

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("div > div > textarea#task_title[name='task[title]'][aria-invalid='true']")
    ensure
      ActionView::Base.field_error_proc = original
    end

    it "renders the frame in a field, with the label for the textarea" do
      render_inline(Gustwave::Form::Field.new(label: "Comment")) do |field|
        field.with_control_textarea(rows: 4) { |textarea| textarea.with_footer { "bar" } }
        nil
      end

      expect(page.find("label")[:for]).to eq(textarea[:id])
      expect(page).to have_css("div.border > div.rounded-t-lg > textarea##{textarea[:id]}")
      expect(page).to have_css("div.border > div.border-t", text: "bar")
    end
  end

  describe "#apply_slot_context" do
    it "binds the textarea to the context's form and attribute" do
      component = described_class.new
      component.apply_slot_context(form: form_builder, attribute: :title)
      render_inline(component)

      expect(textarea[:name]).to eq("task[title]")
    end

    it "keeps the textarea's own form and attribute" do
      component = described_class.new(:title, form: form_builder(name: :own))
      component.apply_slot_context(form: form_builder(name: :other), attribute: :password)
      render_inline(component)

      expect(textarea[:name]).to eq("own[title]")
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(textarea["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(textarea["aria-invalid"]).to be_nil
      expect(textarea_classes).to include("bg-green-50")
    end

    it "takes the ID of a textarea without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(textarea[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(textarea[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(textarea["aria-describedby"]).to eq("hint helper other")
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
