module Gustwave
  module Form
    class FileInputPreview < ViewComponent::Preview
      # Flowbite's "File upload example": a field with a label and a file input for one file.
      def default
        render_with_template
      end

      # Flowbite's "Helper text" example: helper text below the file input that says which files are allowed. Flowbite's
      # helper text uses +mt-1+ and +dark:text-gray-300+, where the field's helper text uses +mt-2+ and +dark:text-gray-400+,
      # so the helper text takes those two classes with +class+.
      def helper_text
        render_with_template
      end

      # Flowbite's "Multiple files" example: +multiple: true+ lets the user pick more than one file.
      def multiple
        render_with_template
      end

      # Flowbite's "Sizes" example: the small, default and large file input, each in a field with a label. The small
      # and default ones have a bottom margin on the file input, as in Flowbite.
      def sizes
        render_with_template
      end

      # Not a Flowbite example. The success and error look of the file input, each with a validation message. The looks
      # follow the input field's.
      def validation
        render_with_template
      end

      # Not a Flowbite example. A disabled file input in a field.
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
