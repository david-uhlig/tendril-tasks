# frozen_string_literal: true

module Form
  class TextFieldComponent < TendrilTasks::Component
    base "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
    def initialize(form, attribute, label = nil, **options)
      @form = form
      @attribute = attribute
      @label = label

      @options = attributes_for(options)
    end

    def call
      field = BaseFieldComponent.new(@form, @attribute, @label)
      render field do
        @form.text_field @attribute, **field.with_error_aria(@options)
      end
    end
  end
end
