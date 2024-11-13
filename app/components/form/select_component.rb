# frozen_string_literal: true

module Form
  class SelectComponent < ApplicationComponent
    SELECT_CLASS = "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"

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
        @form.collection_select @attribute, @collection, @value_method, @text_method, @options, @html_options
      end
    end
  end
end
