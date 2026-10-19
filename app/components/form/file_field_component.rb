# frozen_string_literal: true

module Form
  class FileFieldComponent < TendrilTasks::Component
    base "block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-hidden dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400"

    part :helper_text, "mt-1 text-sm"

    # Renders a helper text below the input field
    #
    # Use to provide additional information about allowed file types, sizes, dimensions, etc.
    #
    # @param text [String] the helper text to display
    # @param options [Hash] additional options to pass to the helper text paragraph
    renders_one :helper_text, ->(text, **options) do
      Gustwave::Paragraph.new(text, **attributes_for(:helper_text, options))
    end

    def initialize(form, attribute, label = nil, **options)
      @form = form
      @attribute = attribute
      @label = label

      @options = attributes_for(options)
    end

    def call
      field = BaseFieldComponent.new(@form, @attribute, @label)
      render field do
        concat @form.file_field @attribute, **field.with_error_aria(@options)
        concat helper_text if helper_text?
      end
    end
  end
end
