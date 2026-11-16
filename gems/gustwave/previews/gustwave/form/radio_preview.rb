module Gustwave
  module Form
    class RadioPreview < ViewComponent::Preview
      # An unchecked and a checked radio, each with its text beside it. The text is the label of a
      # Gustwave::Form::InlineField, which wraps the radio and the label in a cell each, where Flowbite has them side
      # by side in one row. The radios share a +name+.
      def default
        render_with_template
      end

      # A disabled radio and a disabled, checked one. The field grays the label of a disabled control.
      def disabled
        render_with_template
      end

      # A link inside the label, set with the field's +label+ slot.
      def link
        render_with_template
      end

      # The field's helper text under the label. The radio stays beside the label's line and its +aria-describedby+
      # names the helper text.
      def helper_text
        render_with_template
      end

      # A radio in a bordered box whose label fills the box, so a click anywhere beside the radio selects it. The
      # border and the padding are classes on the field and its parts.
      def bordered
        render_with_template
      end

      # A radio in each item of a Gustwave::ListGroup. The radios take darker dark mode classes for the
      # list's background.
      def list_group
        render_with_template
      end

      # Radios next to each other in a flex row.
      def inline
        render_with_template
      end

      # +color+ is +:blue+, +:red+, +:green+, +:purple+, +:teal+, +:yellow+ or +:orange+. The radios are one group, with
      # purple checked: check another to see its color. Blue is the default.
      def colors
        render_with_template
      end

      # Cards that are the labels of hidden radios and take a blue border while their radio is checked. The radio
      # is hidden with +class: "hidden peer"+ and each card is plain Tailwind, a +<label>+ right after its radio,
      # with an arrow from Gustwave::Icon.
      def advanced
        render_with_template
      end

      # A fieldset of radios, the first checked and the last disabled.
      def fieldset
        render_with_template
      end

      # A group of radios in the error state: each field colors its label, and the
      # Gustwave::Form::Fieldset around them renders the validation message once.
      def in_a_field
        render_with_template
      end

      # A radio on its own, without text, named with +aria-label+.
      def standalone
        render_with_template
      end

      # The radio's options, for trying out how they combine.
      # @param color select { choices: [blue, red, green, purple, teal, yellow, orange] }
      # @param validation select { choices: [none, success, error] }
      # @param checked toggle
      # @param disabled toggle
      def playground(color: :blue, validation: :none, checked: false, disabled: false)
        render_with_template(locals: {
          color: color.to_sym,
          validation: validation.to_sym,
          checked: ActiveModel::Type::Boolean.new.cast(checked),
          disabled: ActiveModel::Type::Boolean.new.cast(disabled)
        })
      end
    end
  end
end
