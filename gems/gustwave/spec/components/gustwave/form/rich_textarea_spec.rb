# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichTextarea, type: :component do
  # The editor part's classes and the content class of Lexxy
  def lexxy_editor_classes
    class_set("block w-full min-h-80 px-0 text-sm text-gray-800 border-0 focus:outline-hidden " \
              "dark:bg-gray-800 dark:text-white dark:placeholder-gray-400 lexxy-content")
  end

  # The frame, the first <div> of the component
  def frame
    page.find("div", match: :first)
  end

  # The frame's children in order: the bars and the body
  def frame_children
    frame.all(:xpath, "./*")
  end

  # The editor element. The dummy app has no Lexxy, so Rails' default editor
  # renders; it's the one element with a +toolbar+ attribute.
  def editor
    page.find("[toolbar]")
  end

  def editor_classes
    class_set(editor[:class])
  end

  # The name Rails gives the editor's attribute. Rails' editor keeps it on a
  # hidden input in the dummy app.
  def editor_input(name)
    page.find("input[type='hidden'][name='#{name}']", visible: :all)
  end

  describe "with a form builder" do
    it "renders the default toolbar in the header and the editor in the body, linked by ID" do
      render_inline(described_class.new(:body, form: form_builder(task(body: "Hi"))))

      toolbar_id = page.find("lexxy-toolbar")["id"]
      expect(toolbar_id).to start_with("toolbar-")
      expect(frame_children.map(&:tag_name)).to eq(%w[div div])
      expect(frame_children[0]).to have_css("lexxy-toolbar##{toolbar_id}")
      expect(frame_children[1]).to have_css("[toolbar='#{toolbar_id}']")
      expect(editor[:id]).to eq("task_body")
      expect(editor_input("task[body]").value).to eq("Hi")
      expect(editor_classes).to eq(lexxy_editor_classes)
    end

    it "uses toolbar_id for the toolbar and the editor, and returns it" do
      component = described_class.new(:body, form: form_builder, toolbar_id: "my-toolbar")
      render_inline(component)

      expect(component.toolbar_id).to eq("my-toolbar")
      expect(page).to have_css("lexxy-toolbar#my-toolbar")
      expect(editor[:toolbar]).to eq("my-toolbar")
    end

    it "renders the toolbar in the footer bar, with no header, and rounds the body's top corners" do
      render_inline(described_class.new(:body, form: form_builder)) do |editor|
        editor.with_footer_toolbar
        nil
      end

      expect(frame_children.map(&:tag_name)).to eq(%w[div div])
      expect(frame_children[0]).to have_css("[toolbar]")
      expect(class_set(frame_children[0][:class])).to include("rounded-t-lg")
      expect(frame_children[1]).to have_css("lexxy-toolbar")
    end

    it "passes the hidden toolbar actions to the toolbar" do
      render_inline(described_class.new(:body, form: form_builder)) do |editor|
        editor.with_header_toolbar(hidden: %i[table])
        nil
      end

      expect(page).to have_css("lexxy-toolbar")
      expect(page).to have_no_css("lexxy-toolbar button[name='table']")
    end

    it "shows the table action without hidden:" do
      render_inline(described_class.new(:body, form: form_builder))

      expect(page).to have_css("lexxy-toolbar button[name='table']")
    end

    it "raises for a toolbar in both bars" do
      expect {
        render_inline(described_class.new(:body, form: form_builder)) do |editor|
          editor.with_header_toolbar
          editor.with_footer_toolbar
          nil
        end
      }.to raise_error(ArgumentError, /takes one toolbar/)
    end

    it "raises for a generic header without a toolbar" do
      expect {
        render_inline(described_class.new(:body, form: form_builder)) do |editor|
          editor.with_header_generic { "Title" }
          nil
        end
      }.to raise_error(ArgumentError, /with_footer_toolbar.*toolbar: false/m)
    end

    it "renders a generic header with the toolbar in the footer, with the body's corners square" do
      render_inline(described_class.new(:body, form: form_builder)) do |editor|
        editor.with_header_generic { "Title" }
        editor.with_footer_toolbar
        nil
      end

      expect(frame_children.map(&:tag_name)).to eq(%w[div div div])
      expect(frame_children[0].text).to eq("Title")
      expect(frame_children[1]).to have_css("[toolbar]")
      expect(class_set(frame_children[1][:class])).not_to include("rounded-t-lg", "rounded-b-lg", "rounded-lg")
      expect(frame_children[2]).to have_css("lexxy-toolbar")
    end

    it "renders no toolbar with toolbar: false, and no bars" do
      render_inline(described_class.new(:body, form: form_builder, toolbar: false))

      expect(page).to have_no_css("lexxy-toolbar")
      expect(editor[:toolbar]).to eq("false")
      expect(frame_children.map(&:tag_name)).to eq(%w[div])
      expect(class_set(frame_children[0][:class])).to include("rounded-lg")
    end

    it "raises for a toolbar placed with toolbar: false" do
      expect {
        render_inline(described_class.new(:body, form: form_builder, toolbar: false)) do |editor|
          editor.with_footer_toolbar
          nil
        end
      }.to raise_error(ArgumentError, /got `toolbar:` as an attribute/)
    end

    it "connects a toolbar of the caller's own and builds none" do
      render_inline(described_class.new(:body, form: form_builder, toolbar: "own"))

      expect(editor[:toolbar]).to eq("own")
      expect(page).to have_no_css("lexxy-toolbar")
    end

    it "builds a Trix toolbar and uses the Trix content class with editor: :trix" do
      component = described_class.new(:body, form: form_builder, editor: :trix, toolbar_id: "trix-bar")
      render_inline(component)

      expect(page).to have_css("trix-toolbar#trix-bar")
      expect(page).to have_no_css("lexxy-toolbar")
      expect(editor[:toolbar]).to eq("trix-bar")
      expect(editor_classes).to include("trix-content")
      expect(editor_classes).not_to include("lexxy-content")
    end

    it "sticks the toolbar to the top of the frame by default" do
      render_inline(described_class.new(:body, form: form_builder))

      expect(class_set(frame[:class])).to include("group")
      expect(class_set(frame_children[0][:class])).to include("group-hover:sticky", "top-0")
    end

    it "sticks a footer toolbar to the bottom" do
      render_inline(described_class.new(:body, form: form_builder)) do |editor|
        editor.with_footer_toolbar
        nil
      end

      expect(class_set(frame_children[1][:class])).to include("group-hover:sticky", "bottom-0")
    end

    it "doesn't stick the toolbar with sticky_toolbar: false" do
      render_inline(described_class.new(:body, form: form_builder, sticky_toolbar: false))

      expect(class_set(frame[:class])).not_to include("group")
      expect(page).to have_no_css("div[class~='group-hover:sticky']")
      expect(page).to have_no_css("div[class~='top-0']")
    end

    it "colors the frame's border and sets aria-invalid for the error state" do
      render_inline(described_class.new(:body, form: form_builder, validation: :error))

      expect(class_set(frame[:class])).to include("border-red-500")
      expect(editor["aria-invalid"]).to eq("true")
    end

    it "colors the frame's border green for the success state without aria-invalid" do
      render_inline(described_class.new(:body, form: form_builder, validation: :success))

      expect(class_set(frame[:class])).to include("border-green-500")
      expect(editor["aria-invalid"]).to be_nil
    end

    it "never wraps the editor in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      record = task(body: "Hi")
      record.errors.add(:body, "is invalid")
      form = form_builder(record)

      expect(form.rich_textarea(:body)).to include("field_with_errors")

      render_inline(described_class.new(:body, form:, validation: :error))

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("[id='task_body'][aria-invalid='true']")
      expect(editor_input("task[body]")).to be_present
    ensure
      ActionView::Base.field_error_proc = original
    end

    it "gives the parts' attributes to their elements and the editor's options to the editor" do
      component = described_class.new(:body, form: form_builder, placeholder: "Write", data: { test: "editor" },
                                              frame_options: { class: "mb-4", data: { test: "frame" } },
                                              header_options: { data: { test: "header" } },
                                              body_options: { data: { test: "body" } },
                                              footer_options: { class: "gap-2", data: { test: "footer" } })
      render_inline(component) do |editor|
        editor.with_header_generic { "H" }
        editor.with_footer_toolbar
        nil
      end

      expect(class_set(frame[:class])).to include("mb-4")
      expect(frame["data-test"]).to eq("frame")
      expect(frame_children[0]["data-test"]).to eq("header")
      expect(frame_children[1]["data-test"]).to eq("body")
      expect(frame_children[2]["data-test"]).to eq("footer")
      expect(class_set(frame_children[2][:class])).to include("gap-2")
      expect(editor["data-test"]).to eq("editor")
      expect(frame["placeholder"]).to be_nil
    end

    it "binds an editor set by apply_slot_context and adds the described_by IDs" do
      component = described_class.new
      component.apply_slot_context(form: form_builder(task(body: "Hi")), attribute: :body, validation: :error,
                                   described_by: "helper")
      render_inline(component)

      expect(editor[:id]).to eq("task_body")
      expect(editor_input("task[body]")).to be_present
      expect(editor["aria-invalid"]).to eq("true")
      expect(editor["aria-describedby"]).to eq("helper")
    end

    it "keeps its own validation state when the context gives one" do
      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)

      expect(editor["aria-invalid"]).to be_nil
      expect(class_set(frame[:class])).to include("border-green-500")
    end

    it "has Rails' ID for the attribute as its html_id" do
      expect(described_class.new(:body, form: form_builder).html_id).to eq("task_body")

      component = described_class.new
      component.apply_slot_context(form: form_builder, attribute: :body)
      expect(component.html_id).to eq("task_body")
    end

    it "builds a Trix toolbar bound to the form inside a field" do
      # The Trix toolbar keeps its form but doesn't render it, so check the argument
      expect(Gustwave::Form::RichText::Trix::Toolbar).to receive(:new)
        .with(kind_of(ActionView::Helpers::FormBuilder), id: kind_of(String))
        .and_call_original

      render_inline(Gustwave::Form::Field.new(:body, form: form_builder(task(body: "Hi")))) do |field|
        field.with_control_rich_textarea(editor: :trix) { |editor| editor.with_footer_toolbar }
        nil
      end

      expect(page).to have_css("trix-toolbar")
      expect(editor[:id]).to eq("task_body")
      expect(editor_input("task[body]")).to be_present
      expect(page.find("label")[:for]).to eq("task_body")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:body) }.to raise_error(ArgumentError, /Gustwave::Form::RichTextarea needs `form:`/)
    end
  end

  describe "without a form builder" do
    it "renders the frame and an editor with the given name" do
      render_inline(described_class.new(name: "article[body]", value: "<p>Hi</p>"))

      expect(editor_input("article[body]")).to be_present
      expect(frame_children.map(&:tag_name)).to eq(%w[div div])
      expect(page).to have_css("lexxy-toolbar##{editor[:toolbar]}")
    end
  end
end
