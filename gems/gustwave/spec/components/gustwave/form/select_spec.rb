# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::Select, type: :component do
  helpers = FormSpecHelpers

  let(:countries) { [ [ "Canada", "CA" ], [ "France", "FR" ], [ "Germany", "DE" ] ] }

  def select_element
    page.find("select")
  end

  def select_classes
    class_set(select_element[:class])
  end

  # The text, value and state of every option, optgroups left out
  def option_rows
    page.all("option").map do |option|
      { text: option.text, value: option[:value], selected: option[:selected].present?,
        disabled: option[:disabled].present? }.reject { |_key, value| value == false || value.nil? }
    end
  end

  def option_values = page.all("option").map { |option| option[:value] }

  def selected_values = page.all("option[selected]").map { |option| option[:value] }

  describe "classes" do
    it "carries Flowbite's classes by default" do
      render_inline(described_class.new)

      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT))
    end

    it "carries Flowbite's classes for the sizes" do
      render_inline(described_class.new(size: :sm))
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_SMALL))

      render_inline(described_class.new(size: :md))
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT))

      render_inline(described_class.new(size: :lg))
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_LARGE))
    end

    it "carries the input field's classes for the success and error state" do
      render_inline(described_class.new(validation: :success))
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_INPUT_SUCCESS))

      render_inline(described_class.new(validation: :error))
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_INPUT_ERROR))
    end

    it "carries Flowbite's classes for the underline style" do
      render_inline(described_class.new(style: :underline))

      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_UNDERLINE))
    end

    it "gives the underline style no size or validation classes" do
      %i[sm md lg].product(%i[none success error]).each do |size, validation|
        render_inline(described_class.new(style: :underline, size:, validation:))

        expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_UNDERLINE)), "#{size} #{validation}"
      end
    end

    it "accepts a string naming the size or style" do
      render_inline(described_class.new(size: "lg", style: "default"))

      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_LARGE))
      expect(select_element[:size]).to be_nil
      expect(select_element[:style]).to be_nil
    end

    it "raises for an unknown size or style symbol" do
      expect { described_class.new(size: :huge) }.to raise_error(Gustwave::Options::UnknownValueError)
      expect { described_class.new(style: :pills) }.to raise_error(Gustwave::Options::UnknownValueError)
    end

    it "has no disabled look, as Flowbite's disabled select is the default one" do
      render_inline(described_class.new(disabled: true))

      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT))
      expect(select_element[:disabled]).to be_present
    end

    it "keeps the validation look for a disabled select" do
      render_inline(described_class.new(disabled: true, validation: :error))

      expect(select_classes).to eq(class_set(helpers::FLOWBITE_INPUT_ERROR))
    end

    it "adds the caller's classes, which win conflicts" do
      render_inline(described_class.new(class: "mx-4 bg-white p-8"))

      expect(select_classes).to include("mx-4", "bg-white", "p-8")
      expect(select_classes).not_to include("bg-gray-50", "p-2.5")
    end
  end

  describe "size and style as HTML attributes, in html:" do
    it "renders both attributes next to the Flowbite size" do
      render_inline(described_class.new(size: :lg, html: { size: 5, style: "min-width: 12rem" }))

      expect(select_element[:size]).to eq("5")
      expect(select_element[:style]).to eq("min-width: 12rem")
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_LARGE))
    end

    it "renders the style attribute next to the underline style" do
      render_inline(described_class.new(style: :underline, html: { style: "color: red" }))

      expect(select_element[:style]).to eq("color: red")
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT_UNDERLINE))
    end

    it "raises for a size or style that isn't one of its values, and names html:" do
      expect { described_class.new(size: 5) }
        .to raise_error(Gustwave::Options::UnknownValueError, /pass html: \{ size: 5 \}\./)
      expect { described_class.new(style: "min-width: 12rem") }
        .to raise_error(Gustwave::Options::UnknownValueError, /pass html: \{ style: "min-width: 12rem" \}\./)
    end

    it "falls back to the defaults when Gustwave isn't strict" do
      Gustwave.strict = false
      render_inline(described_class.new(size: 5, style: "color: red"))

      expect(select_element[:size]).to be_nil
      expect(select_element[:style]).to be_nil
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT))
    end
  end

  describe "validation" do
    it "sets aria-invalid in the error state only" do
      render_inline(described_class.new(validation: :error))
      expect(select_element["aria-invalid"]).to eq("true")

      render_inline(described_class.new(validation: :success))
      expect(select_element["aria-invalid"]).to be_nil
    end

    it "sets aria-invalid for the underline style, too" do
      render_inline(described_class.new(validation: :error, style: :underline))

      expect(select_element["aria-invalid"]).to eq("true")
    end

    it "lets the caller's aria-invalid win" do
      render_inline(described_class.new(validation: :error, aria: { invalid: false }))

      expect(select_element["aria-invalid"]).to eq("false")
    end
  end

  describe "without a form" do
    it "renders a plain select with HTML attributes and no ID of its own" do
      render_inline(described_class.new(name: "country", required: true, aria: { label: "Country" }, data: { x: "1" },
                                        choices: countries))

      expect(page).to have_css("select[name='country'][data-x='1']")
      expect(select_element[:id]).to be_nil
      expect(select_element[:required]).to be_present
      expect(select_element["aria-label"]).to eq("Country")
      expect(page).to have_no_css("div, input")
    end

    it "renders the caller's ID" do
      render_inline(described_class.new(name: "country", id: "countries"))

      expect(select_element[:id]).to eq("countries")
    end

    it "adds [] to the name of a multiple select, once" do
      render_inline(described_class.new(name: "countries", multiple: true))
      expect(select_element[:name]).to eq("countries[]")
      expect(select_element[:multiple]).to be_present

      render_inline(described_class.new(name: "countries[]", multiple: true))
      expect(select_element[:name]).to eq("countries[]")

      render_inline(described_class.new(name: "country"))
      expect(select_element[:name]).to eq("country")
    end

    it "renders no name for a select without one" do
      render_inline(described_class.new(multiple: true))

      expect(select_element[:name]).to be_nil
    end

    it "renders no hidden field for a multiple select, as select_tag" do
      render_inline(described_class.new(name: "countries", multiple: true))

      expect(page).to have_no_css("input", visible: :all)
    end

    it "raises for an attribute without a form" do
      expect { described_class.new(:country) }.to raise_error(ArgumentError, /Gustwave::Form::Select needs `form:`/)
    end
  end

  describe "choices" do
    it "renders a flat array as text and value" do
      render_inline(described_class.new(choices: %w[Canada France]))

      expect(option_rows).to eq([ { text: "Canada", value: "Canada" }, { text: "France", value: "France" } ])
    end

    it "renders pairs of text and value" do
      render_inline(described_class.new(choices: countries))

      expect(option_rows.map { |row| row.values_at(:text, :value) }).to eq(countries)
    end

    it "renders a hash of text to value" do
      render_inline(described_class.new(choices: { "Canada" => "CA", "France" => "FR" }))

      expect(option_rows.map { |row| row.values_at(:text, :value) }).to eq([ %w[Canada CA], %w[France FR] ])
    end

    it "renders a range" do
      render_inline(described_class.new(choices: 2016..2018))

      expect(option_values).to eq(%w[2016 2017 2018])
    end

    it "renders grouped choices in optgroups" do
      render_inline(described_class.new(choices: { "North America" => [ %w[Canada CA] ], "Europe" => [ %w[France FR], %w[Germany DE] ] }))

      expect(page).to have_css("optgroup[label='North America'] > option[value='CA']")
      expect(page).to have_css("optgroup[label='Europe'] > option[value='FR'] + option[value='DE']")
    end

    it "renders a string of option tags as it is" do
      tags = vc_test_controller.view_context.options_for_select(countries, "FR")
      render_inline(described_class.new(choices: tags))

      expect(option_values).to eq(%w[CA FR DE])
      expect(selected_values).to eq([ "FR" ])
    end

    it "renders the block as the option tags" do
      render_inline(described_class.new(name: "country")) { "<option value=\"x\">X</option>".html_safe }

      expect(option_values).to eq([ "x" ])
    end

    it "prefers the block to the choices" do
      render_inline(described_class.new(choices: countries)) { "<option value=\"x\">X</option>".html_safe }

      expect(option_values).to eq([ "x" ])
    end

    it "renders an empty select without choices" do
      render_inline(described_class.new)

      expect(page).to have_css("select")
      expect(page).to have_no_css("option")
    end

    it "escapes the text of the options" do
      render_inline(described_class.new(choices: [ "<b>Bold</b>" ]))

      expect(page).to have_no_css("b")
    end
  end

  describe "Rails' select options" do
    it "renders a prompt first, with an empty value" do
      render_inline(described_class.new(choices: countries, prompt: "Choose a country"))

      expect(option_rows.first).to eq({ text: "Choose a country", value: "" })
      expect(option_values).to eq([ "", "CA", "FR", "DE" ])
    end

    it "renders a blank option for include_blank" do
      render_inline(described_class.new(choices: countries, include_blank: true))
      expect(option_values).to eq([ "", "CA", "FR", "DE" ])

      render_inline(described_class.new(choices: countries, include_blank: "None"))
      expect(option_rows.first).to eq({ text: "None", value: "" })
    end

    it "selects the given values" do
      render_inline(described_class.new(choices: countries, selected: "FR"))
      expect(selected_values).to eq([ "FR" ])

      render_inline(described_class.new(choices: countries, selected: %w[CA DE], multiple: true))
      expect(selected_values).to eq(%w[CA DE])
    end

    it "selects nothing for selected: nil" do
      render_inline(described_class.new(choices: [ [ "Canada", "CA" ], [ "None", "" ] ], selected: nil))

      expect(selected_values).to be_empty
    end

    it "disables the options of disabled_choices" do
      render_inline(described_class.new(choices: countries, disabled_choices: %w[FR DE]))

      expect(page.all("option[disabled]").map { |option| option[:value] }).to eq(%w[FR DE])
      expect(select_element[:disabled]).to be_nil
    end

    it "keeps disabled for the whole select an HTML attribute" do
      render_inline(described_class.new(choices: countries, disabled: true))

      expect(select_element[:disabled]).to be_present
      expect(page).to have_no_css("option[disabled]")
    end

    it "renders a hidden field of a bound multiple select unless include_hidden is false" do
      render_inline(described_class.new(:tags, form: form_builder, choices: %w[a b], multiple: true))
      expect(page).to have_css("input[type='hidden'][name='task[tags][]'] + select[multiple]", visible: :all)

      render_inline(described_class.new(:tags, form: form_builder, choices: %w[a b], multiple: true, include_hidden: false))
      expect(page).to have_no_css("input", visible: :all)
    end
  end

  describe "with a form" do
    it "renders name, ID and the record's value as Rails does" do
      render_inline(described_class.new(:country, form: form_builder(task(country: "FR")), choices: countries))

      expect(select_element[:name]).to eq("task[country]")
      expect(select_element[:id]).to eq("task_country")
      expect(selected_values).to eq([ "FR" ])
    end

    it "renders the same markup as Rails' select, apart from the classes" do
      form = form_builder(task(country: "FR"))
      rails = Capybara.string(form.select(:country, countries, { include_blank: true }, { required: true, data: { x: 1 } }))
      render_inline(described_class.new(:country, form:, choices: countries, include_blank: true, required: true, data: { x: 1 }))

      ours = select_element
      expect(ours[:name]).to eq(rails.find("select")[:name])
      expect(ours[:id]).to eq(rails.find("select")[:id])
      expect(ours[:required]).to eq(rails.find("select")[:required])
      expect(ours["data-x"]).to eq("1")
      expect(option_rows).to eq(rails.all("option").map do |option|
        { text: option.text, value: option[:value], selected: option[:selected].present? }.reject { |_key, value| value == false }
      end)
    end

    it "selects what the caller gave over the record's value" do
      render_inline(described_class.new(:country, form: form_builder(task(country: "FR")), choices: countries, selected: "DE"))

      expect(selected_values).to eq([ "DE" ])
    end

    it "selects nothing for selected: nil" do
      render_inline(described_class.new(:country, form: form_builder(task(country: "FR")), choices: countries, selected: nil))

      expect(selected_values).to be_empty
    end

    it "renders a prompt only without a value, as Rails does" do
      render_inline(described_class.new(:country, form: form_builder(task(country: "FR")), choices: countries, prompt: "Choose"))
      expect(option_values).to eq(%w[CA FR DE])

      render_inline(described_class.new(:country, form: form_builder(task), choices: countries, prompt: "Choose"))
      expect(option_values).to eq([ "", "CA", "FR", "DE" ])
    end

    it "disables options" do
      render_inline(described_class.new(:country, form: form_builder, choices: countries, disabled_choices: "FR"))

      expect(page.all("option[disabled]").map { |option| option[:value] }).to eq([ "FR" ])
    end

    it "takes the option tags from the block, with the record's value selected" do
      form = form_builder(task(country: "FR"))
      render_inline(described_class.new(:country, form:)) { vc_test_controller.view_context.options_for_select(countries, "DE") }

      expect(option_values).to eq(%w[CA FR DE])
      expect(selected_values).to eq([ "DE" ])
    end

    it "renders a multiple select with a hidden field and the record's values selected" do
      render_inline(described_class.new(:tags, form: form_builder(task(tags: %w[b])), choices: %w[a b c], multiple: true))

      expect(select_element[:name]).to eq("task[tags][]")
      expect(select_element[:id]).to eq("task_tags")
      expect(page).to have_css("input[type='hidden'][name='task[tags][]'][value='']", visible: :all)
      expect(selected_values).to eq(%w[b])
    end

    it "renders through Gustwave::FormBuilder's own form as Rails does" do
      render_inline(described_class.new(:country, form: form_builder(task, builder: Gustwave::FormBuilder), choices: countries))

      expect(page).to have_css("select#task_country[name='task[country]']")
      expect(page).to have_no_css("label")
    end

    it "follows the builder's index and namespace" do
      render_inline(described_class.new(:country, form: form_builder(index: 3, namespace: "ns"), choices: countries))

      expect(select_element[:name]).to eq("task[3][country]")
      expect(select_element[:id]).to eq("ns_task_3_country")
    end

    it "lets the caller's id and name win" do
      render_inline(described_class.new(:country, form: form_builder, id: "my-country", name: "my[country]"))

      expect(select_element[:id]).to eq("my-country")
      expect(select_element[:name]).to eq("my[country]")
    end

    it "renders the size attribute of a bound select from html:" do
      render_inline(described_class.new(:country, form: form_builder, choices: countries, html: { size: 5 }))

      expect(select_element[:size]).to eq("5")
      expect(select_classes).to eq(class_set(helpers::FLOWBITE_SELECT))
    end

    it "renders a builder for a url-only form" do
      render_inline(described_class.new(:country, form: form_builder(nil, name: nil), choices: countries))

      expect(select_element[:name]).to eq("country")
    end

    it "never wraps the select in Rails' field_error_proc" do
      original = ActionView::Base.field_error_proc
      ActionView::Base.field_error_proc = proc { |html, _| "<div class=\"field_with_errors\">#{html}</div>".html_safe }
      form = form_builder(invalid_task)

      expect(form.select(:title, [ "a" ])).to include("field_with_errors")

      render_inline(described_class.new(:title, form:, choices: [ "a" ], validation: :error))

      expect(page).to have_no_css(".field_with_errors")
      expect(page).to have_css("select#task_title[aria-invalid='true']")
    ensure
      ActionView::Base.field_error_proc = original
    end
  end

  describe "#apply_slot_context" do
    it "binds the select to the context's form and attribute" do
      component = described_class.new(choices: countries)
      component.apply_slot_context(form: form_builder(task(country: "CA")), attribute: :country)
      render_inline(component)

      expect(select_element[:name]).to eq("task[country]")
      expect(selected_values).to eq([ "CA" ])
    end

    it "keeps the select's own form and attribute" do
      component = described_class.new(:country, form: form_builder(name: :own))
      component.apply_slot_context(form: form_builder(name: :other), attribute: :title)
      render_inline(component)

      expect(select_element[:name]).to eq("own[country]")
    end

    it "takes the validation state unless the caller picked one" do
      component = described_class.new
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(select_element["aria-invalid"]).to eq("true")

      component = described_class.new(validation: :success)
      component.apply_slot_context(validation: :error)
      render_inline(component)
      expect(select_element["aria-invalid"]).to be_nil
      expect(select_classes).to include("bg-green-50")
    end

    it "takes the ID of a select without a form, unless the caller gave one" do
      component = described_class.new
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(select_element[:id]).to eq("from-field")

      component = described_class.new(id: "own")
      component.apply_slot_context(id: "from-field")
      render_inline(component)
      expect(select_element[:id]).to eq("own")
    end

    it "merges described_by with the caller's aria-describedby" do
      component = described_class.new(aria: { describedby: "hint" })
      component.apply_slot_context(described_by: "helper other")
      render_inline(component)

      expect(select_element["aria-describedby"]).to eq("hint helper other")
    end

    it "ignores keys it doesn't know" do
      expect { described_class.new.apply_slot_context(slot: :control, other: 1) }.not_to raise_error
    end
  end

  describe "#html_id" do
    it "is the caller's ID, the context's ID or Rails' ID for the attribute" do
      expect(described_class.new(id: "own").html_id).to eq("own")
      expect(described_class.new(:country, form: form_builder).html_id).to eq("task_country")
      expect(described_class.new.html_id).to be_nil

      component = described_class.new
      component.apply_slot_context(id: "ctx")
      expect(component.html_id).to eq("ctx")
    end

    it "agrees with the ID Rails renders for a multiple select" do
      component = described_class.new(:tags, form: form_builder, choices: %w[a b], multiple: true)
      render_inline(component)

      expect(select_element[:id]).to eq("task_tags")
      expect(component.html_id).to eq(select_element[:id])
    end
  end
end
