# frozen_string_literal: true

module Form
  class ToggleComponent < TendrilTasks::Component
    CHECKBOX_STATE_CLASSES = "text-sm font-medium text-gray-900 dark:text-gray-300"
    TOGGLE_BUTTON_CLASSES = "relative w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 rounded-full peer dark:bg-gray-700 peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:w-5 after:h-5 after:transition-all dark:border-gray-600 peer-checked:bg-blue-600"

    renders_one :checked_state_text_slot, ->(text, **options) do
      options.deep_symbolize_keys!
      options[:class] = class_merge("me-3", CHECKBOX_STATE_CLASSES, options.delete(:class))
      tag.span(text, **options)
    end
    alias checked_state_text with_checked_state_text_slot

    renders_one :unchecked_state_text_slot, ->(text, **options) do
      options.deep_symbolize_keys!
      options[:class] = class_merge("ms-3", CHECKBOX_STATE_CLASSES, options.delete(:class))
      tag.span(text, **options)
    end
    alias unchecked_state_text with_unchecked_state_text_slot

    def initialize(form, attribute, label = nil, **options)
      @form = form
      @attribute = attribute
      @label = label
      @check_box_options = { class: "sr-only peer" }
      @check_box_options[:checked] = options.delete(:checked) if options.key?(:checked)
      @options = build_options(options)
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:class] = class_merge(
        TOGGLE_BUTTON_CLASSES,
        options.delete(:class)
      )
      options
    end
  end
end
