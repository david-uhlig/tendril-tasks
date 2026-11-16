module Gustwave
  module Form
    class TogglePreview < ViewComponent::Preview
      # A toggle with its text next to it. The text is the label of a Gustwave::Form::InlineField, a sibling of
      # the toggle's own label around the switch, where Flowbite has one label around both.
      def default
        render_with_template
      end

      # +checked: true+ turns the toggle on by default.
      def checked
        render_with_template
      end

      # A disabled toggle and a disabled, checked one. The field grays the label of a disabled control.
      def disabled
        render_with_template
      end

      # +color+ is +:blue+, +:red+, +:green+, +:purple+, +:yellow+, +:teal+ or +:orange+. Each toggle is checked,
      # so its color shows. Blue is the default.
      def colors
        render_with_template
      end

      # +size+ is +:sm+, +:md+ or +:lg+.
      def sizes
        render_with_template
      end

      # A toggle, a checked one and a disabled one. Flowbite keeps the text of the disabled toggle dark there, so
      # its label takes the dark classes.
      def toggle_switch
        render_with_template
      end

      # A toggle in an inline field with helper text under its label, and one in the error state with a validation
      # message.
      def in_a_field
        render_with_template
      end

      # A toggle on its own, without text, named with +aria-label+.
      def standalone
        render_with_template
      end

      # The toggle's options, for trying out how they combine.
      # @param size select { choices: [sm, md, lg] }
      # @param color select { choices: [blue, red, green, purple, yellow, teal, orange] }
      # @param validation select { choices: [none, success, error] }
      # @param checked toggle
      # @param disabled toggle
      def playground(size: :md, color: :blue, validation: :none, checked: false, disabled: false)
        render_with_template(locals: {
          size: size.to_sym,
          color: color.to_sym,
          validation: validation.to_sym,
          checked: ActiveModel::Type::Boolean.new.cast(checked),
          disabled: ActiveModel::Type::Boolean.new.cast(disabled)
        })
      end
    end
  end
end
