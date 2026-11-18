# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Range, type: :component do
  it_behaves_like "a bound control defaulting to the error state", slot: :range, id: "task_%s"

  # Flowbite's "Default range" example, the default range
  flowbite_range = "w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"

  def range_input
    page.find("input[type='range']")
  end

  def range_classes
    class_set(range_input[:class])
  end

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(range_classes).to eq(class_set(flowbite_range))
    end

    it "carries the track's height for each size" do
      render_inline(described_class.new(size: :sm))
      expect(range_classes).to include("h-1", "range-sm")
      expect(range_classes).not_to include("h-2", "h-3", "range-lg")

      render_inline(described_class.new(size: :md))
      expect(range_classes).to include("h-2")
      expect(range_classes).not_to include("h-1", "h-3", "range-sm", "range-lg")

      render_inline(described_class.new(size: :lg))
      expect(range_classes).to include("h-3", "range-lg")
      expect(range_classes).not_to include("h-1", "h-2", "range-sm")
    end

    it "adds no class when disabled, as the plugin grays the thumb" do
      render_inline(described_class.new(disabled: true))

      expect(range_input[:disabled]).to be_present
      expect(range_classes).to eq(class_set(flowbite_range))
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "mx-4 bg-white"))

      expect(range_classes).to include("mx-4", "bg-white")
      expect(range_classes).not_to include("bg-gray-200")
    end
  end

  describe "HTML attributes" do
    it "passes min, max, step and value through" do
      render_inline(described_class.new(name: "volume", min: 0, max: 10, step: 0.5, value: 5))

      expect(range_input[:min]).to eq("0")
      expect(range_input[:max]).to eq("10")
      expect(range_input[:step]).to eq("0.5")
      expect(range_input[:value]).to eq("5")
    end

    it "renders the size attribute from html:, next to the size option" do
      render_inline(described_class.new(size: :lg, html: { size: 5 }))

      expect(range_input[:size]).to eq("5")
      expect(range_classes).to include("h-3", "range-lg")
    end

    it "renders a plain range input with HTML attributes" do
      render_inline(described_class.new(name: "volume", id: "volume", aria: { label: "Volume" }))

      expect(page).to have_css("input[type='range'][name='volume'][id='volume']")
      expect(range_input["aria-label"]).to eq("Volume")
      expect(page).to have_no_css("div")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state and adds no class" do
      render_inline(described_class.new(validation: :error))

      expect(range_input["aria-invalid"]).to eq("true")
      expect(range_classes).to eq(class_set(flowbite_range))
    end

    it "sets no aria-invalid in the success state and adds no class" do
      render_inline(described_class.new(validation: :success))

      expect(range_input["aria-invalid"]).to be_nil
      expect(range_classes).to eq(class_set(flowbite_range))
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(range_input["aria-invalid"]).to eq("false")
    end

    it "is :error while the bound attribute has errors, and :none otherwise" do
      record = task(progress: 40).tap { |task| task.errors.add(:progress, "is invalid") }

      render_inline(described_class.new(:progress, form: form_builder(record)))
      expect(range_input["aria-invalid"]).to eq("true")

      render_inline(described_class.new(:title, form: form_builder(record)))
      expect(range_input["aria-invalid"]).to be_nil
    end

    it "lets its own validation win over the errors of the bound attribute" do
      record = task(progress: 40).tap { |task| task.errors.add(:progress, "is invalid") }

      render_inline(described_class.new(:progress, form: form_builder(record), validation: :none))

      expect(range_input["aria-invalid"]).to be_nil
    end
  end

  describe "with a form" do
    it "renders name, id and value from the record, as Rails does" do
      render_inline(described_class.new(:progress, form: form_builder(task(progress: 40)), min: 0, max: 100))

      expect(range_input[:type]).to eq("range")
      expect(range_input[:name]).to eq("task[progress]")
      expect(range_input[:id]).to eq("task_progress")
      expect(range_input[:value]).to eq("40")
      expect(range_input[:min]).to eq("0")
      expect(range_input[:max]).to eq("100")
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:progress, form: form_builder, id: "my-range", name: "my[range]"))

      expect(range_input[:id]).to eq("my-range")
      expect(range_input[:name]).to eq("my[range]")
    end

    it "renders through Gustwave::FormBuilder's own form as Rails does" do
      render_inline(described_class.new(:progress, form: form_builder(task(progress: 40), builder: Gustwave::FormBuilder)))

      expect(page).to have_css("input[type='range']#task_progress[name='task[progress]'][value='40']")
      expect(page).to have_no_css("label")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:progress, form: form_builder(index: 3, namespace: "ns")))

      expect(range_input[:name]).to eq("task[3][progress]")
      expect(range_input[:id]).to eq("ns_task_3_progress")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:progress) }.to raise_error(ArgumentError, /Gustwave::Form::Range needs `form:`/)
    end
  end

  describe "#apply_slot_context" do
    it "binds the range to the context's form and attribute" do
      component = described_class.new
      component.apply_slot_context(form: form_builder(task(progress: 40)), attribute: :progress)
      render_inline(component)

      expect(range_input[:name]).to eq("task[progress]")
      expect(range_input[:value]).to eq("40")
    end

    it "keeps the range's own form and attribute" do
      component = described_class.new(:progress, form: form_builder(name: :own))
      component.apply_slot_context(form: form_builder(name: :other), attribute: :password)
      render_inline(component)

      expect(range_input[:name]).to eq("own[progress]")
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(range_input["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(range_input["aria-invalid"]).to be_nil
    end

    it "takes the ID of a range without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(range_input[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(range_input[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(range_input["aria-describedby"]).to eq("hint helper other")
    end

    it "ignores keys it doesn't know" do
      expect { described_class.new.apply_slot_context(slot: :control, other: 1) }.not_to raise_error
    end
  end
end
