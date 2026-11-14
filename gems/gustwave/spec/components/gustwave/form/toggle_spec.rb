# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Toggle, type: :component do
  # Flowbite's "Toggle example": the default toggle
  flowbite_track = "relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 " \
                   "dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full " \
                   "rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] " \
                   "after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border " \
                   "after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 " \
                   "peer-checked:bg-blue-600 dark:peer-checked:bg-blue-600"

  def checkbox
    page.find("input[type='checkbox']", visible: :all)
  end

  def label
    page.find("label")
  end

  def track
    page.find("label > div")
  end

  def track_classes
    class_set(track[:class])
  end

  def text
    page.find("label > span")
  end

  describe "markup" do
    it "renders Flowbite's label around a hidden checkbox, the track and the text" do
      render_inline(described_class.new(value: "")) { "Toggle me" }

      expect(class_set(label[:class])).to eq(class_set("inline-flex items-center cursor-pointer"))
      expect(class_set(checkbox[:class])).to eq(class_set("sr-only peer"))
      expect(checkbox[:value]).to eq("")
      expect(page).to have_css("label > input[type='checkbox'] + div + span")
      expect(class_set(text[:class])).to eq(class_set("ms-3 text-sm font-medium text-gray-900 dark:text-gray-300"))
      expect(text.text).to eq("Toggle me")
    end

    it "renders no text without a block" do
      render_inline(described_class.new(aria: { label: "Notify me" }))

      expect(page).to have_no_css("span")
      expect(checkbox["aria-label"]).to eq("Notify me")
    end

    it "sends the options to the checkbox" do
      render_inline(described_class.new(name: "n", id: "n", checked: true, required: true, class: "extra"))

      expect(checkbox[:name]).to eq("n")
      expect(checkbox[:id]).to eq("n")
      expect(checkbox[:checked]).to be_present
      expect(checkbox[:required]).to be_present
      expect(class_set(checkbox[:class])).to include("extra", "sr-only", "peer")
    end

    it "styles the parts with their options" do
      render_inline(described_class.new(label_options: { class: "mb-5", data: { a: "1" } },
                                        track_options: { class: "shadow-xs" },
                                        text_options: { class: "font-bold" })) { "Text" }

      expect(class_set(label[:class])).to include("mb-5")
      expect(label["data-a"]).to eq("1")
      expect(track_classes).to include("shadow-xs")
      expect(class_set(text[:class])).to include("font-bold")
      expect(class_set(text[:class])).not_to include("font-medium")
    end

    it "takes the size attribute from html:" do
      render_inline(described_class.new(size: :lg, html: { size: 3 }))

      expect(checkbox[:size]).to eq("3")
      expect(track_classes).to include("w-14")
    end
  end

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(track_classes).to eq(class_set(flowbite_track))
    end

    # Flowbite's "Sizes" example
    {
      sm: %w[w-9 h-5 after:top-[2px] after:start-[2px] after:h-4 after:w-4],
      md: %w[w-11 h-6 after:top-[2px] after:start-[2px] after:h-5 after:w-5],
      lg: %w[w-14 h-7 after:top-0.5 after:start-[4px] after:h-6 after:w-6]
    }.each do |size, classes|
      it "carries the classes of the #{size} size and no other size's" do
        render_inline(described_class.new(size:))

        expect(track_classes).to include(*classes)
        other = %w[w-9 w-11 w-14 h-5 h-6 h-7] - classes
        expect(track_classes).not_to include(*other)
      end
    end

    # Flowbite's "Colors" example: the focus ring and the checked background
    {
      blue: %w[blue-300 blue-800 blue-600],
      red: %w[red-300 red-800 red-600],
      green: %w[green-300 green-800 green-600],
      purple: %w[purple-300 purple-800 purple-600],
      yellow: %w[yellow-300 yellow-800 yellow-400],
      teal: %w[teal-300 teal-800 teal-600],
      orange: %w[orange-300 orange-800 orange-500]
    }.each do |color, (ring, dark_ring, checked)|
      it "carries the #{color} classes" do
        render_inline(described_class.new(color:))

        expect(track_classes).to include("peer-focus:ring-#{ring}", "dark:peer-focus:ring-#{dark_ring}",
                                         "peer-checked:bg-#{checked}", "dark:peer-checked:bg-#{checked}")
        other_colors = %w[blue red green purple yellow teal orange] - [ color.to_s ]
        expect(track_classes.grep(/peer-(focus:ring|checked:bg)-(#{other_colors.join('|')})-/)).to be_empty
      end
    end

    it "grays the text of a disabled toggle, as Flowbite's disabled example does" do
      render_inline(described_class.new(disabled: true)) { "Disabled toggle" }

      expect(checkbox[:disabled]).to be_present
      expect(class_set(text[:class])).to include("text-gray-400", "dark:text-gray-500")
      expect(class_set(text[:class])).not_to include("text-gray-900", "dark:text-gray-300")
    end

    it "doesn't look disabled for required" do
      render_inline(described_class.new(required: true)) { "Text" }

      expect(class_set(text[:class])).to include("text-gray-900")
    end

    it "adds the caller's classes to the checkbox, which win conflicts" do
      render_inline(described_class.new(color: :red, track_options: { class: "bg-gray-300 w-20" }))

      expect(track_classes).to include("bg-gray-300", "w-20")
      expect(track_classes).not_to include("bg-gray-200", "w-11")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only, without a look" do
      render_inline(described_class.new)
      default_classes = track_classes

      render_inline(described_class.new(validation: :error))
      expect(checkbox["aria-invalid"]).to eq("true")
      expect(track_classes).to eq(default_classes)

      render_inline(described_class.new(validation: :success))
      expect(checkbox["aria-invalid"]).to be_nil
      expect(track_classes).to eq(default_classes)
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
      expect(checkbox[:type]).to eq("checkbox")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:published) }.to raise_error(ArgumentError, /Gustwave::Form::Toggle needs `form:`/)
    end
  end

  describe "with a form" do
    it "renders name, id and the hidden field as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task)))

      expect(page).to have_css("label > input[type='hidden'][name='task[title]'][value='0']", visible: :all)
      expect(checkbox[:name]).to eq("task[title]")
      expect(checkbox[:id]).to eq("task_title")
      expect(checkbox[:value]).to eq("1")
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

    it "renders through Gustwave::FormBuilder's own form as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task, builder: Gustwave::FormBuilder)))

      expect(page).to have_css("input[type='checkbox']#task_title[name='task[title]']", visible: :all)
    end

    it "never wraps the toggle in Rails' field_error_proc" do
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
    it "binds the toggle to the context's form and attribute" do
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

    it "takes the ID of a toggle without a form, unless the caller gave one" do
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
  end
end
