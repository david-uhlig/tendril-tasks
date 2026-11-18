module Gustwave
  module Form
    class RangePreview < ViewComponent::Preview
      # A slider with a label above it, at its default value of 50 out of 0 to 100.
      def default
        render_with_template
      end

      # A slider that can't be changed. The page's CSS grays its thumb, not a class on the slider.
      def disabled
        render_with_template
      end

      # A slider from 0 to 10 that starts at 5.
      def min_max
        render_with_template
      end

      # A slider that moves in half steps, from 0 to 5, and starts at 2.5.
      def steps
        render_with_template
      end

      # The small, default and large slider, each with a label above it. The small and default ones have a bottom
      # margin on the slider.
      def sizes
        render_with_template
      end

      # A slider with labels under its track at $100, $500, $1000 and $1500. The labels are spans that the caller
      # positions in a relative wrapper, because the range has no tick labels of its own.
      def labels
        render_with_template
      end

      # A slider in a field with helper text, and a slider in a field with an error and its message. The error look
      # is the field's: the label and the message turn red, and the slider is marked invalid.
      def in_a_field
        render_with_template
      end

      # A slider on its own, without a label, named with +aria-label+.
      def standalone
        render_with_template
      end

      # The slider's options, for trying out how they combine.
      # @param size select { choices: [sm, md, lg] }
      # @param validation select { choices: [none, success, error] }
      # @param disabled toggle
      # @param min [Integer] number
      # @param max [Integer] number
      # @param step [Float] number
      # @param value [Float] number
      def playground(size: :md, validation: :none, disabled: false, min: 0, max: 100, step: 1, value: 50)
        render_with_template(locals: {
          size: size.to_sym,
          validation: validation.to_sym,
          disabled: ActiveModel::Type::Boolean.new.cast(disabled),
          min: min,
          max: max,
          step: step,
          value: value
        })
      end
    end
  end
end
