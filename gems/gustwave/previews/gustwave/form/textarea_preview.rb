module Gustwave
  module Form
    class TextareaPreview < ViewComponent::Preview
      # Flowbite's "Textarea example": a field with a label and a textarea of four rows.
      def default
        render_with_template
      end

      # Flowbite's "Chatroom input": an upload and an emoji button, a one-row textarea and a send button in a rounded
      # bar. The buttons are plain Tailwind with an icon each: Gustwave's buttons don't have their classes. The
      # textarea changes the default's margin and background with +class+.
      def chatroom
        render_with_template
      end

      # Not a Flowbite example. The success and error look of the textarea, each with a validation message. The looks
      # follow the input field's.
      def validation
        render_with_template
      end

      # Not a Flowbite example. A disabled textarea in a field.
      def disabled
        render_with_template
      end

      # The textarea's options, for trying out how they combine.
      # @param validation select { choices: [none, success, error] }
      # @param disabled toggle
      # @param rows number
      # @param placeholder text
      def playground(validation: :none, disabled: false, rows: 4, placeholder: "Write your thoughts here...")
        render_with_template(locals: {
          validation: validation.to_sym,
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          rows: rows.to_i,
          placeholder: placeholder
        })
      end
    end
  end
end
