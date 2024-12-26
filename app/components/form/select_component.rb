# frozen_string_literal: true

module Form
  class SelectComponent < TendrilTasks::Component
    SELECT_CLASS = "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"

    renders_one :leading_button_slot, ::ButtonComponent
    alias leading_button with_leading_button_slot

    renders_one :trailing_button_slot, ::ButtonComponent
    alias trailing_button with_trailing_button_slot

    def initialize(form, attribute, label, collection, value_method, text_method, error_field_attribute: nil, **options)
      @form = form
      @attribute = attribute
      @error_field_attribute = error_field_attribute || @attribute
      @value_method = value_method
      @text_method = text_method
      @label = label
      @options = options
      @html_options = {}
      @html_options[:class] = SELECT_CLASS
      @collection = collection
    end

    def call
      render BaseFieldComponent.new(@form, @attribute, @label, @error_field_attribute) do
        tag.div class: "flex gap-2" do
          concat leading_button_slot if leading_button_slot?
          concat @form.collection_select @attribute, @collection, @value_method, @text_method, @options, @html_options
          concat trailing_button_slot if trailing_button_slot?
        end
      end
    end
  end
end
