# frozen_string_literal: true

module Form
  class FileFieldComponent < TendrilTasks::Component
    style :base,
          "block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 dark:text-gray-400 focus:outline-none dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400"

    style :helper_text,
          "mt-1 text-sm text-gray-500 dark:text-gray-300"

    # Renders a helper text below the input field
    #
    # Use to provide additional information about allowed file types, sizes, dimensions, etc.
    #
    # @param text [String] the helper text to display
    # @param options [Hash] additional options to pass to the helper text paragraph
    renders_one :helper_text_slot, ->(text, **options) do
      options.symbolize_keys!
      options[:class] = styles(helper_text: true,
                               custom: options.delete(:class))

      tag.p text, **options
    end
    # Alias for helper_text_slot
    alias helper_text with_helper_text_slot

    def initialize(form, attribute, label = nil, **options)
      @form = form
      @attribute = attribute
      @label = label

      options.symbolize_keys!
      options[:class] = styles(base: true, custom: options.delete(:class))
      @options = options
    end

    def call
      render BaseFieldComponent.new(@form, @attribute, @label) do
        concat @form.file_field @attribute, **@options
        concat helper_text_slot if helper_text_slot?
      end
    end
  end
end
