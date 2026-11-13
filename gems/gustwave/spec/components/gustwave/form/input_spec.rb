# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Input, type: :component do
  helpers = FormSpecHelpers

  def input
    page.find("input")
  end

  def input_classes
    class_set(input[:class])
  end

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT))
    end

    it "carries Flowbite's classes for the large and small size" do
      render_inline(described_class.new(size: :lg))
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_LARGE))

      render_inline(described_class.new(size: :sm))
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_SMALL))
    end

    it "accepts a string naming the size" do
      render_inline(described_class.new(size: "lg"))

      expect(page.find("input")[:size]).to be_nil
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_LARGE))
    end

    it "renders the size attribute from html:, next to the size option" do
      render_inline(described_class.new(size: :lg, html: { size: 20 }))

      expect(page.find("input")[:size]).to eq("20")
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_LARGE))
    end

    it "renders the size attribute of a bound input from html:" do
      render_inline(described_class.new(:title, form: form_builder, html: { size: 20 }))

      expect(page.find("input")[:size]).to eq("20")
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT))
    end

    it "raises for a size that isn't one of its sizes, and names html:" do
      expect { described_class.new(size: 20) }
        .to raise_error(Gustwave::Options::UnknownValueError, /For the HTML attribute, pass html: \{ size: 20 \}\./)
      expect { described_class.new(size: "20") }
        .to raise_error(Gustwave::Options::UnknownValueError, /html: \{ size: "20" \}/)
    end

    it "falls back to the default size when Gustwave isn't strict" do
      Gustwave.strict = false
      render_inline(described_class.new(size: 20))

      expect(page.find("input")[:size]).to be_nil
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT))
    end

    it "lets html: set the type attribute" do
      render_inline(described_class.new(type: :email, html: { type: "text" }))

      expect(page.find("input")[:type]).to eq("text")
    end

    it "carries Flowbite's classes for the success and error state" do
      render_inline(described_class.new(validation: :success))
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_SUCCESS))

      render_inline(described_class.new(validation: :error))
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_ERROR))
    end

    it "carries Flowbite's classes for the disabled state" do
      render_inline(described_class.new(disabled: true, value: "Disabled input"))

      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_DISABLED))
      expect(input[:disabled]).to be_present
    end

    it "doesn't look disabled for readonly or required" do
      render_inline(described_class.new(readonly: true, required: true))

      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT))
      expect(input[:readonly]).to be_present
      expect(input[:required]).to be_present
    end

    it "keeps the disabled cursor in the validation states" do
      render_inline(described_class.new(disabled: true, validation: :error))

      expect(input_classes).to include("cursor-not-allowed", "bg-red-50")
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "p-8 shadow-xs"))

      expect(input_classes).to include("p-8", "shadow-xs")
      expect(input_classes).not_to include("p-2.5")
    end
  end

  describe "types" do
    described_class::HELPERS.each_key do |type|
      it "renders type #{type}" do
        render_inline(described_class.new(type:))

        expect(input[:type]).to eq(type.to_s.tr("_", "-"))
      end
    end

    it "defaults to text" do
      render_inline(described_class.new)

      expect(input[:type]).to eq("text")
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only" do
      render_inline(described_class.new(validation: :error))
      expect(input["aria-invalid"]).to eq("true")

      render_inline(described_class.new(validation: :success))
      expect(input["aria-invalid"]).to be_nil
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(input["aria-invalid"]).to eq("false")
    end
  end

  describe "a leading icon" do
    it "renders Flowbite's input group" do
      render_inline(described_class.new(icon: :envelope, placeholder: "name@flowbite.com"))

      expect(page).to have_css("div.relative > div.absolute.inset-y-0.start-0.flex.items-center.ps-3\\.5.pointer-events-none > svg")
      expect(page).to have_css("div.relative > input")
      expect(input_classes).to eq(class_set(helpers::FLOWBITE_INPUT_WITH_ICON))
      expect(input[:placeholder]).to eq("name@flowbite.com")
    end

    it "renders a filled icon like Flowbite's, hidden from screen readers" do
      render_inline(described_class.new(icon: :envelope))

      svg = page.find("svg")
      expect(svg[:fill]).to eq("currentColor")
      expect(svg[:"aria-hidden"]).to eq("true")
      expect(class_set(svg[:class])).to eq(class_set("h-5 w-5 -ms-0.5 text-gray-500 dark:text-gray-400"))
    end

    it "renders it for a visual set through the slot" do
      render_inline(described_class.new) { |component| component.with_leading_visual_icon(:envelope) }

      expect(page).to have_css("div.relative > div.absolute > svg")
      expect(input_classes).to include("ps-10")
    end

    it "keeps the icon size and the start padding at every size" do
      %i[sm md lg].each do |size|
        render_inline(described_class.new(icon: :envelope, size:))

        expect(input_classes).to include("ps-10")
        expect(class_set(page.find("svg")[:class])).to include("h-5", "w-5", "-ms-0.5")
      end
    end

    it "renders the bare input without a visual" do
      render_inline(described_class.new)

      expect(page).to have_no_css("div")
      expect(page).to have_css("input")
    end

    it "puts the options on the input, not the wrapper" do
      render_inline(described_class.new(icon: :envelope, id: "mail", class: "shadow-xs"))

      expect(page).to have_css("input#mail.shadow-xs")
      expect(page.find("div.relative")[:id]).to be_nil
    end
  end

  describe "without a form" do
    it "renders a plain input with name, id and value as attributes" do
      render_inline(described_class.new(name: "q", id: "search", value: "rails", type: :search, aria: { label: "Search" }))

      expect(input[:name]).to eq("q")
      expect(input[:id]).to eq("search")
      expect(input[:value]).to eq("rails")
      expect(input[:type]).to eq("search")
      expect(input["aria-label"]).to eq("Search")
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:title) }.to raise_error(ArgumentError, /form:/)
    end
  end

  describe "with a form" do
    it "renders name, id and value as Rails does" do
      render_inline(described_class.new(:title, form: form_builder(task(title: "Write specs"))))

      expect(input[:name]).to eq("task[title]")
      expect(input[:id]).to eq("task_title")
      expect(input[:value]).to eq("Write specs")
      expect(input[:type]).to eq("text")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:title, form: form_builder(index: 3, namespace: "ns")))

      expect(input[:name]).to eq("task[3][title]")
      expect(input[:id]).to eq("ns_task_3_title")
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:title, form: form_builder, id: "my-title", name: "my[title]"))

      expect(input[:id]).to eq("my-title")
      expect(input[:name]).to eq("my[title]")
    end

    it "formats a date value for a date input" do
      render_inline(described_class.new(:due_on, form: form_builder(task(due_on: Date.new(2026, 3, 9))), type: :date))

      expect(input[:type]).to eq("date")
      expect(input[:value]).to eq("2026-03-09")
    end

    it "doesn't echo a password" do
      render_inline(described_class.new(:password, form: form_builder(task(password: "secret")), type: :password))

      expect(input[:type]).to eq("password")
      expect(input[:value]).to be_nil
    end

    it "renders a builder without an object" do
      render_inline(described_class.new(:title, form: form_builder(nil, name: :task, value: "x"), value: "x"))

      expect(input[:name]).to eq("task[title]")
      expect(input[:id]).to eq("task_title")
    end

    it "renders a builder for a url-only form" do
      render_inline(described_class.new(:title, form: form_builder(nil, name: nil)))

      expect(input[:name]).to eq("title")
    end

    it "never wraps the input in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      form = form_builder(invalid_task)

      expect(form.text_field(:title)).to include("field_with_errors")

      render_inline(described_class.new(:title, form:, validation: :error))

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("input#task_title[aria-invalid='true']")
    ensure
      ActionView::Base.field_error_proc = original
    end

    it "renders the input with a leading icon through Rails" do
      render_inline(described_class.new(:title, form: form_builder, icon: :envelope))

      expect(page).to have_css("div.relative input#task_title")
    end
  end

  describe "#apply_slot_context" do
    it "binds the input to the context's form and attribute" do
      component = described_class.new
      component.apply_slot_context(form: form_builder, attribute: :title)
      render_inline(component)

      expect(input[:name]).to eq("task[title]")
    end

    it "keeps the input's own form and attribute" do
      component = described_class.new(:title, form: form_builder(name: :own))
      component.apply_slot_context(form: form_builder(name: :other), attribute: :password)
      render_inline(component)

      expect(input[:name]).to eq("own[title]")
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(input["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(input["aria-invalid"]).to be_nil
      expect(input_classes).to include("bg-green-50")
    end

    it "takes the ID of an input without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(input[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(input[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(input["aria-describedby"]).to eq("hint helper other")
    end

    it "sets aria-describedby without one from the caller" do
      component = described_class.new
      component.apply_slot_context(described_by: "helper")
      render_inline(component)

      expect(input["aria-describedby"]).to eq("helper")
    end

    it "ignores keys it doesn't know" do
      expect { described_class.new.apply_slot_context(slot: :control, other: 1) }.not_to raise_error
    end
  end
end
