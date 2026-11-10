module Gustwave
  module Form
    class InputPreview < ViewComponent::Preview
      # Flowbite's "Input fields" example: an account form with the fields in a two-column grid. Every field is a
      # Form::Field with a Form::Input. The terms checkbox is plain Tailwind, because Gustwave has no checkbox yet.
      def default
        render_with_template
      end

      # Flowbite's "Input sizes" example: the large, default and small input, each in a field with a label.
      def sizes
        render_with_template
      end

      # Flowbite's "Disabled state" example: a disabled input and a disabled read-only input. They have no field,
      # so they take an +aria-label+ instead of a label.
      def disabled
        render_with_template
      end

      # Flowbite's "Validation" example: a field in the success and one in the error state. The label, the input
      # and the message take the state's color, and the message starts in bold.
      def validation
        render_with_template
      end

      # Flowbite's "Input group" example, first variant: an icon inside the input at its start. The second variant,
      # a text or icon addon attached to the input, isn't built yet.
      def group
        render_with_template
      end

      # Flowbite's "Helper text" example: helper text below the input, with a link. The field ties it to the input
      # with +aria-describedby+.
      def helper_text
        render_with_template
      end

      # The input's options side by side, for trying out how they combine.
      # @param type select { choices: [text, email, password, number, url, tel, search, date, time, datetime_local, month, week] }
      # @param size select { choices: [sm, md, lg] }
      # @param validation select { choices: [none, success, error] }
      # @param icon select { choices: [none, envelope, search, users, profile_card] }
      # @param disabled toggle
      # @param placeholder text
      def playground(type: :text, size: :md, validation: :none, icon: :none, disabled: false, placeholder: "Task title")
        render_with_template(locals: {
          type: type.to_sym,
          size: size.to_sym,
          validation: validation.to_sym,
          icon: (icon.to_sym unless icon.to_s == "none"),
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          placeholder: placeholder
        })
      end
    end
  end
end
