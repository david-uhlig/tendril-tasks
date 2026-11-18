module Gustwave
  module Form
    class InputPreview < ViewComponent::Preview
      # An account form with the fields in a two-column grid. Every field is a Form::Field with a Form::Input,
      # and the terms checkbox a Form::InlineField with a Form::Checkbox.
      def default
        render_with_template
      end

      # The large, default and small input, each in a field with a label.
      def sizes
        render_with_template
      end

      # A disabled input and a disabled read-only input. They have no field, so they take an +aria-label+ instead
      # of a label.
      def disabled
        render_with_template
      end

      # A field in the success and one in the error state. The label, the input and the message take the state's
      # color, and the message starts in bold.
      def validation
        render_with_template
      end

      # An icon inside the input at its start, and a text or icon addon attached to the input in an input group.
      def group
        render_with_template
      end

      # Helper text below the input, with a link. The field ties it to the input with +aria-describedby+.
      def helper_text
        render_with_template
      end

      # A large search input with a search icon and a search button inside it, in a field with a hidden label.
      def search
        render_with_template
      end

      # A search input with a branch icon and an icon-only search button beside it.
      def search_simple
        render_with_template
      end

      # A search input with a palette icon, a microphone button at its end for voice search, and a search button
      # beside it. The microphone button has an accessible name, which the Flowbite example lacks.
      def search_voice
        render_with_template
      end

      # A search input in each size, each with a search icon and a search button inside it.
      def search_sizes
        render_with_template
      end

      # The input's options side by side, for trying out how they combine.
      # @param type select { choices: [text, email, password, number, url, tel, search, date, time, datetime_local, month, week] }
      # @param size select { choices: [sm, md, lg] }
      # @param validation select { choices: [none, success, error] }
      # @param icon select { choices: [none, envelope, search, users, profile_card] }
      # @param trailing_action select { choices: [none, button] }
      # @param disabled toggle
      # @param placeholder text
      def playground(type: :text, size: :md, validation: :none, icon: :none, trailing_action: :none, disabled: false, placeholder: "Task title")
        render_with_template(locals: {
          type: type.to_sym,
          size: size.to_sym,
          validation: validation.to_sym,
          icon: (icon.to_sym unless icon.to_s == "none"),
          trailing_action: (trailing_action.to_sym unless trailing_action.to_s == "none"),
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          placeholder: placeholder
        })
      end
    end
  end
end
