# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Radio, type: :component do
  # Flowbite's "Radio example": the default radio
  flowbite_radio = "w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 focus:ring-blue-500 " \
                   "dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 " \
                   "dark:border-gray-600"

  def radio
    page.find("input[type='radio']")
  end

  def radio_classes
    class_set(radio[:class])
  end

  describe "markup" do
    it "renders only the radio, without a label or a wrapper" do
      render_inline(described_class.new(value: "free", aria: { label: "Free plan" }))

      expect(page.all("body > *", visible: :all).map(&:tag_name)).to eq(%w[input])
      expect(radio[:value]).to eq("free")
      expect(radio["aria-label"]).to eq("Free plan")
    end

    it "sends the options to the radio" do
      render_inline(described_class.new(name: "n", id: "n", checked: true, required: true, class: "extra", data: { a: "1" }))

      expect(radio[:name]).to eq("n")
      expect(radio[:id]).to eq("n")
      expect(radio[:checked]).to be_present
      expect(radio[:required]).to be_present
      expect(radio["data-a"]).to eq("1")
      expect(radio_classes).to include("extra", "w-4", "h-4")
    end

    it "takes HTML attributes from html:" do
      render_inline(described_class.new(html: { name: "n", title: "Free plan" }))

      expect(radio[:name]).to eq("n")
      expect(radio[:title]).to eq("Free plan")
    end
  end

  describe "classes" do
    it "carries Flowbite's classes by default, and no rounded-sm" do
      render_inline(described_class.new)

      expect(radio_classes).to eq(class_set(flowbite_radio))
      expect(radio_classes).not_to include("rounded-sm")
    end

    # Flowbite's "Colors" example: the checked button, the focus ring and the dark focus ring
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

        expect(radio_classes).to include(*classes)
        other_colors = %w[blue red green purple teal yellow orange] - [ color.to_s ]
        expect(radio_classes.grep(/(text|ring)-(#{other_colors.join('|')})-/)).to be_empty
      end
    end

    it "keeps its classes when disabled, as Flowbite's disabled example does" do
      render_inline(described_class.new(disabled: true))

      expect(radio[:disabled]).to be_present
      expect(radio_classes).to eq(class_set(flowbite_radio))
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "w-5 dark:bg-gray-600"))

      expect(radio_classes).to include("w-5", "dark:bg-gray-600", "h-4")
      expect(radio_classes).not_to include("w-4", "dark:bg-gray-700")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only, without a look" do
      render_inline(described_class.new(validation: :error))
      expect(radio["aria-invalid"]).to eq("true")
      expect(radio_classes).to eq(class_set(flowbite_radio))

      render_inline(described_class.new(validation: :success))
      expect(radio["aria-invalid"]).to be_nil
      expect(radio_classes).to eq(class_set(flowbite_radio))
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(radio["aria-invalid"]).to eq("false")
    end
  end

  describe "without a form" do
    it "renders a plain radio without a hidden field" do
      render_inline(described_class.new(name: "n", value: "1"))

      expect(page).to have_css("input", count: 1, visible: :all)
      expect(radio[:value]).to eq("1")
    end

    it "needs no value" do
      expect { render_inline(described_class.new(name: "n")) }.not_to raise_error
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:plan) }.to raise_error(ArgumentError, /Gustwave::Form::Radio needs `form:`/)
    end
  end

  describe "with a form" do
    it "renders name, value and id as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task), value: "free"))

      expect(page).to have_css("input", count: 1, visible: :all)
      expect(radio[:name]).to eq("task[title]")
      expect(radio[:value]).to eq("free")
      expect(radio[:id]).to eq("task_title_free")
      expect(radio[:checked]).to be_nil
      expect(radio_classes).to eq(class_set(flowbite_radio))
    end

    it "checks the radio whose value is the record's value" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "free")), value: "free"))
      expect(radio[:checked]).to be_present

      render_inline(described_class.new(:title, form: form_builder(task(title: "free")), value: "pro"))
      expect(radio[:checked]).to be_nil
    end

    it "lets the caller's checked win" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "free")), value: "free", checked: false))
      expect(radio[:checked]).to be_nil

      render_inline(described_class.new(:title, form: form_builder(task(title: "free")), value: "pro", checked: true))
      expect(radio[:checked]).to be_present
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:title, form: form_builder, value: "free", id: "mine", name: "my[name]"))

      expect(radio[:id]).to eq("mine")
      expect(radio[:name]).to eq("my[name]")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:title, form: form_builder(index: 3, namespace: "ns"), value: "free"))

      expect(radio[:name]).to eq("task[3][title]")
      expect(radio[:id]).to eq("ns_task_3_title_free")
    end

    it "renders through Gustwave::FormBuilder's own form as Rails does, without a field" do
      render_inline(described_class.new(:title, form: form_builder(task, builder: Gustwave::FormBuilder), value: "free"))

      expect(page).to have_css("input[type='radio']#task_title_free[name='task[title]']")
      expect(page).to have_no_css("label")
    end

    it "never wraps the radio in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }

      render_inline(described_class.new(:title, form: form_builder(invalid_task), value: "free", validation: :error))

      expect(page).to have_no_css(".field_with_errors", visible: :all)
      expect(radio["aria-invalid"]).to eq("true")
    ensure
      ActionView::Base.field_error_proc = original
    end

    it "raises without a value" do
      expect { render_inline(described_class.new(:title, form: form_builder)) }
        .to raise_error(ArgumentError, "Gustwave::Form::Radio needs `value:` for the attribute :title.")
    end
  end

  describe "#apply_slot_context" do
    it "binds the radio to the context's form and attribute" do
      component = described_class.new(value: "free")
      component.apply_slot_context(form: form_builder, attribute: :title)
      render_inline(component)

      expect(radio[:name]).to eq("task[title]")
      expect(radio[:id]).to eq("task_title_free")
    end

    it "raises without a value when it is bound through the context" do
      component = described_class.new
      component.apply_slot_context(form: form_builder, attribute: :title)

      expect { render_inline(component) }.to raise_error(ArgumentError, /needs `value:` for the attribute :title/)
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(radio["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(radio["aria-invalid"]).to be_nil
    end

    it "takes the ID of a radio without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(radio[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(radio[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(radio["aria-describedby"]).to eq("hint helper other")
    end

    it "ignores keys it doesn't know" do
      expect { described_class.new.apply_slot_context(slot: :control, other: 1) }.not_to raise_error
    end
  end

  describe "#html_id" do
    it "is the caller's ID, or nil for an unbound radio without one" do
      expect(described_class.new(id: "own").html_id).to eq("own")
      expect(described_class.new.html_id).to be_nil
    end

    it "is the ID Rails gives a bound radio, with the sanitized value" do
      [
        [ form_builder, "free", "task_title_free" ],
        [ form_builder, "In Progress 2.0!", "task_title_in_progress_2_0" ],
        [ form_builder(index: 3, namespace: "ns"), "free", "ns_task_3_title_free" ]
      ].each do |form, value, id|
        component = described_class.new(:title, form:, value:)
        render_inline(component)

        expect(component.html_id).to eq(id)
        expect(radio[:id]).to eq(id)
      end
    end

    it "is the ID Rails gives a bound radio whose value is nil, without a suffix" do
      component = described_class.new(:title, form: form_builder, value: nil)
      render_inline(component)

      expect(radio[:id]).to eq("task_title")
      expect(component.html_id).to eq("task_title")
    end

    it "is the caller's ID for a bound radio" do
      expect(described_class.new(:title, form: form_builder, value: "free", id: "own").html_id).to eq("own")
    end
  end

  describe "#value" do
    it "is the value the radio stands for" do
      expect(described_class.new(value: "free").value).to eq("free")
      expect(described_class.new.value).to be_nil
    end
  end

  describe "#disabled?" do
    it "says whether the radio is disabled" do
      expect(described_class.new(disabled: true)).to be_disabled
      expect(described_class.new).not_to be_disabled
    end
  end
end
