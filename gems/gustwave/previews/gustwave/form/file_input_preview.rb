module Gustwave
  module Form
    class FileInputPreview < ViewComponent::Preview
      # A field with a label and a file input for one file.
      def default
        render_with_template
      end

      # Helper text below the file input that says which files are allowed. Flowbite's helper text uses +mt-1+ and
      # +dark:text-gray-300+, where the field's helper text uses +mt-2+ and +dark:text-gray-400+, so the helper text takes
      # those two classes with +class+.
      def helper_text
        render_with_template
      end

      # +multiple: true+ lets the user pick more than one file.
      def multiple
        render_with_template
      end

      # The small, default and large file input, each in a field with a label. The small and default ones have a
      # bottom margin on the file input.
      def sizes
        render_with_template
      end

      # The success and error look of the file input, each with a validation message. The looks follow the input
      # field's.
      def validation
        render_with_template
      end

      # A disabled file input in a field.
      def disabled
        render_with_template
      end

      # The file input's options, for trying out how they combine.
      # @param size select { choices: [sm, md, lg] }
      # @param validation select { choices: [none, success, error] }
      # @param disabled toggle
      # @param multiple toggle
      def playground(size: :md, validation: :none, disabled: false, multiple: false)
        render_with_template(locals: {
          size: size.to_sym,
          validation: validation.to_sym,
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          multiple: ActiveModel::Type::Boolean.new.cast(multiple)
        })
      end
    end
  end
end
