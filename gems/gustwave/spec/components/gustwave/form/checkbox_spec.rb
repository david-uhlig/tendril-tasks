# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Checkbox, type: :component do
  # Flowbite's "Checkbox example": the default checkbox
  flowbite_checkbox = "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded-sm focus:ring-blue-500 " \
                      "dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 " \
                      "dark:border-gray-600"

  def checkbox
    page.find("input[type='checkbox']")
  end

  def checkbox_classes
    class_set(checkbox[:class])
  end

  describe "markup" do
    it "renders only the checkbox, without a label or a wrapper" do
      render_inline(described_class.new(value: "", aria: { label: "Notify me" }))

      expect(page.all("body > *", visible: :all).map(&:tag_name)).to eq(%w[input])
      expect(checkbox[:value]).to eq("")
      expect(checkbox["aria-label"]).to eq("Notify me")
    end

    it "sends the options to the checkbox" do
      render_inline(described_class.new(name: "n", id: "n", checked: true, required: true, class: "extra", data: { a: "1" }))

      expect(checkbox[:name]).to eq("n")
      expect(checkbox[:id]).to eq("n")
      expect(checkbox[:checked]).to be_present
      expect(checkbox[:required]).to be_present
      expect(checkbox["data-a"]).to eq("1")
      expect(checkbox_classes).to include("extra", "w-4", "h-4")
    end

    it "takes HTML attributes from html:" do
      render_inline(described_class.new(html: { name: "n", title: "Notify me" }))

      expect(checkbox[:name]).to eq("n")
      expect(checkbox[:title]).to eq("Notify me")
    end
  end

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(checkbox_classes).to eq(class_set(flowbite_checkbox))
    end

    # Flowbite's "Colors" example: the checked box, the focus ring and the dark focus ring
    {
      blue: %w[text-blue-600 focus:ring-blue-500 dark:focus:ring-blue-600],
      red: %w[text-red-600 focus:ring-red-500 dark:focus:ring-red-600],
      green: %w[text-green-600 focus:ring-green-500 dark:focus:ring-green-600],
      purple: %w[text-purple-600 focus:ring-purple-500 dark:focus:ring-purple-600],
      teal: %w[text-teal-600 focus:ring-teal-500 dark:focus:ring-teal-600],
      yellow: %w[text-yellow-400 focus:ring-yellow-500 dark:focus:ring-yellow-600],
      orange: %w[text-orange-500 focus:ring-orange-500 dark:focus:ring-orange-600]
    }.each do |color, classes|
      it "carries the #{color} classes and no other color's" do
        render_inline(described_class.new(color:))

        expect(checkbox_classes).to include(*classes)
        other_colors = %w[blue red green purple teal yellow orange] - [ color.to_s ]
        expect(checkbox_classes.grep(/(text|ring)-(#{other_colors.join('|')})-/)).to be_empty
      end
    end

    it "keeps its classes when disabled, as Flowbite's disabled example does" do
      render_inline(described_class.new(disabled: true))

      expect(checkbox[:disabled]).to be_present
      expect(checkbox_classes).to eq(class_set(flowbite_checkbox))
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "w-5 dark:bg-gray-600"))

      expect(checkbox_classes).to include("w-5", "dark:bg-gray-600", "h-4")
      expect(checkbox_classes).not_to include("w-4", "dark:bg-gray-700")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only, without a look" do
      render_inline(described_class.new(validation: :error))
      expect(checkbox["aria-invalid"]).to eq("true")
      expect(checkbox_classes).to eq(class_set(flowbite_checkbox))

      render_inline(described_class.new(validation: :success))
      expect(checkbox["aria-invalid"]).to be_nil
      expect(checkbox_classes).to eq(class_set(flowbite_checkbox))
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(checkbox["aria-invalid"]).to eq("false")
    end
  end

  describe "without a form" do
    it "renders a plain checkbox without a hidden field" do
      render_inline(described_class.new(name: "n", value: "1"))

      expect(page).to have_css("input", count: 1, visible: :all)
      expect(checkbox[:value]).to eq("1")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:published) }.to raise_error(ArgumentError, /Gustwave::Form::Checkbox needs `form:`/)
    end
  end

  describe "with a form" do
    it "renders name, id and the hidden field as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task)))

      expect(page.all("body > input", visible: :all).map { _1[:type] }).to eq(%w[hidden checkbox])
      expect(page).to have_css("input[type='hidden'][name='task[title]'][value='0']", visible: :all)
      expect(checkbox[:name]).to eq("task[title]")
      expect(checkbox[:id]).to eq("task_title")
      expect(checkbox[:value]).to eq("1")
      expect(checkbox_classes).to eq(class_set(flowbite_checkbox))
    end

    it "checks the box for a record whose value is the checked value" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "1"))))

      expect(checkbox[:checked]).to be_present
    end

    it "takes Rails' checked and unchecked values and include_hidden" do
      render_inline(described_class.new(:title, form: form_builder, checked_value: "yes", unchecked_value: "no"))
      expect(checkbox[:value]).to eq("yes")
      expect(page).to have_css("input[type='hidden'][value='no']", visible: :all)

      render_inline(described_class.new(:title, form: form_builder, include_hidden: false))
      expect(page).to have_no_css("input[type='hidden']", visible: :all)
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:title, form: form_builder, id: "mine", name: "my[name]"))

      expect(checkbox[:id]).to eq("mine")
      expect(checkbox[:name]).to eq("my[name]")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:title, form: form_builder(index: 3, namespace: "ns")))

      expect(checkbox[:name]).to eq("task[3][title]")
      expect(checkbox[:id]).to eq("ns_task_3_title")
    end

    it "renders through Gustwave::FormBuilder's own form as Rails does, without a field" do
      render_inline(described_class.new(:title, form: form_builder(task, builder: Gustwave::FormBuilder)))

      expect(page).to have_css("input[type='checkbox']#task_title[name='task[title]']")
      expect(page).to have_no_css("label")
    end

    it "never wraps the checkbox in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }

      render_inline(described_class.new(:title, form: form_builder(invalid_task), validation: :error))

      expect(page).to have_no_css(".field_with_errors", visible: :all)
      expect(checkbox["aria-invalid"]).to eq("true")
    ensure
      ActionView::Base.field_error_proc = original
    end
  end

  describe "#apply_slot_context" do
    it "binds the checkbox to the context's form and attribute" do
      component = described_class.new
      component.apply_slot_context(form: form_builder, attribute: :title)
      render_inline(component)

      expect(checkbox[:name]).to eq("task[title]")
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(checkbox["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(checkbox["aria-invalid"]).to be_nil
    end

    it "takes the ID of a checkbox without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(checkbox[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(checkbox[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(checkbox["aria-describedby"]).to eq("hint helper other")
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
    end

    it "is the ID Rails gives a multiple checkbox, with the checked value" do
      [
        [ form_builder, "a" ],
        [ form_builder, "In Progress 2.0!" ],
        [ form_builder(index: 3, namespace: "ns"), "a" ]
      ].each do |form, checked_value|
        component = described_class.new(:title, form:, multiple: true, checked_value:, unchecked_value: nil)
        render_inline(component)

        expect(component.html_id).to eq(checkbox[:id])
        expect(checkbox[:id]).to end_with("_title_#{checked_value == "a" ? "a" : "in_progress_2_0"}")
      end
    end

    it "is the context's or the caller's ID for a multiple checkbox, and Rails' plain ID without a checked value" do
      expect(described_class.new(:title, form: form_builder, multiple: true, id: "own").html_id).to eq("own")

      component = described_class.new(:title, form: form_builder, multiple: true, checked_value: nil)
      render_inline(component)
      expect(component.html_id).to eq(checkbox[:id])
    end
  end

  describe "#disabled?" do
    it "says whether the checkbox is disabled" do
      expect(described_class.new(disabled: true)).to be_disabled
      expect(described_class.new).not_to be_disabled
    end
  end
end
