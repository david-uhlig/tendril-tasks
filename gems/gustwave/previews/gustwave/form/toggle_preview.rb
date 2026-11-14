module Gustwave
  module Form
    class TogglePreview < ViewComponent::Preview
      # Flowbite's "Toggle example": a toggle with its text next to it.
      def default
        render_with_template
      end

      # Flowbite's "Checked state": +checked: true+ turns the toggle on by default.
      def checked
        render_with_template
      end

      # Flowbite's "Disabled state": a disabled toggle and a disabled, checked one. The text turns gray.
      def disabled
        render_with_template
      end

      # Flowbite's "Colors": +color+ is +:blue+, +:red+, +:green+, +:purple+, +:yellow+, +:teal+ or +:orange+. Each
      # toggle is checked, so its color shows. Blue is the default and Flowbite's example leaves it out.
      def colors
        render_with_template
      end

      # Flowbite's "Sizes": +size+ is +:sm+, +:md+ or +:lg+.
      def sizes
        render_with_template
      end

      # Flowbite's "Toggle Switch" example on its forms page: a toggle, a checked one and a disabled one. Flowbite
      # keeps the text of the disabled toggle dark there, so it takes the text's classes with +text_options+.
      def toggle_switch
        render_with_template
      end

      # Not a Flowbite example. A toggle in a field, which puts its label above the switch, with helper text, and a
      # toggle with its own text and a validation message.
      def in_a_field
        render_with_template
      end

      # Not a Flowbite example. A toggle that is its own label, in a field without a label.
      def field_without_label
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
