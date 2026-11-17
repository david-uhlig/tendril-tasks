module Gustwave
  module Form
    class SelectPreview < ViewComponent::Preview
      # A field with a label and a select. The first option, "Choose a country", is the +prompt+. Like the other
      # select previews, it sits in a +form+ that is centered and at most +max-w-sm+ wide.
      def default
        render_with_template
      end

      # +multiple: true+ makes the select a list box. The first option is selected.
      def multiple
        render_with_template
      end

      # +html: { size: 5 }+ is the HTML attribute, which shows five options of the list. The select keeps the default
      # size, because the +size+ keyword is Gustwave's size.
      def size_attribute
        render_with_template
      end

      # A disabled select, with the input's disabled look.
      def disabled
        render_with_template
      end

      # +style: :underline+. The label is hidden, so it takes +sr-only+.
      def underline
        render_with_template
      end

      # The small, default and large select, each in a field with a label. The large one's label is +text-base+.
      def sizes
        render_with_template
      end

      # The success and error look of the select, each with a validation message. The looks follow the input
      # field's.
      def validation
        render_with_template
      end

      # The select's options, for trying out how they combine. The underline style ignores size and validation.
      # @param size select { choices: [sm, md, lg] }
      # @param style select { choices: [default, underline] }
      # @param validation select { choices: [none, success, error] }
      # @param disabled toggle
      # @param multiple toggle
      def playground(size: :md, style: :default, validation: :none, disabled: false, multiple: false)
        render_with_template(locals: {
          size: size.to_sym,
          style: style.to_sym,
          validation: validation.to_sym,
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          multiple: ActiveModel::Type::Boolean.new.cast(multiple)
        })
      end
    end
  end
end
