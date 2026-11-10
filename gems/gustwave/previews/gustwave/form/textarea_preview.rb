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

      # Flowbite's "WYSIWYG Editor": a textarea in a frame with a header of toolbar buttons, and a publish button below.
      # The buttons are plain Tailwind and do nothing: Gustwave doesn't have a toolbar. For a real editor, use
      # Gustwave::Form::RichTextarea.
      def wysiwyg
        render_with_template
      end

      # Flowbite's "Comment box": a textarea in a frame with a footer of a submit button and icon buttons, and a
      # guidelines paragraph below. The buttons are plain Tailwind and do nothing. For a real editor, use
      # Gustwave::Form::RichTextarea.
      def comment_box
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
      # @param frame select { choices: [none, header, footer, both] }
      def playground(validation: :none, disabled: false, rows: 4, placeholder: "Write your thoughts here...", frame: :none)
        render_with_template(locals: {
          validation: validation.to_sym,
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          rows: rows.to_i,
          placeholder: placeholder,
          frame: frame.to_sym
        })
      end
    end
  end
end
