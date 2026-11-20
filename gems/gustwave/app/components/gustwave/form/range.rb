# frozen_string_literal: true

module Gustwave
  module Form
    # Use Range to render a slider that picks a number between +min+ and +max+.
    # Like every control, it renders on its own or bound to a form builder, and
    # Gustwave::Form::Field renders it with its label above the track: see
    # {file:README.md#Building_forms Building forms}.
    #
    #   <%= render Gustwave::Form::Range.new(name: "volume", min: 0, max: 10, value: 5, aria: { label: "Volume" }) %>
    #   <%= render Gustwave::Form::Range.new(:progress, form: f, min: 0, max: 100, step: 5) %>
    #
    # Flowbite's plugin styles the thumb: its color, its gray when the range is
    # disabled, and its size, which +size+ picks. The range has no color option.
    #
    # @status alpha
    class Range < Gustwave::Component
      include Gustwave::Form::BoundControl

      # Flowbite's range track. Flowbite's plugin styles the thumb, grays it
      # when the range is disabled, and sizes it with range-sm and range-lg.
      part :root, "w-full bg-gray-200 rounded-lg appearance-none cursor-pointer dark:bg-gray-700"

      # The height of the track, and the size of the thumb through the plugin
      variant :size, default: :md, values: {
        sm: "h-1 range-sm",
        md: "h-2",
        lg: "h-3 range-lg"
      }

      # Flowbite shows no validation look for the range, so the state only
      # sets +aria-invalid+.
      option :validation, default: :none, values: %i[none success error]

      # @param attribute [Symbol, String, nil] the attribute of the form's object the range is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the range is a plain +<input type="range">+.
      # @param size [Symbol] the size of the track and the thumb. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+. The HTML attribute +size+ goes in +html:+.
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ sets +aria-invalid+, unless the caller's +aria+ options say otherwise. The state has no look.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +name+, +id+, +min+, +max+, +step+, +value+, +disabled+, +list+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, size: DEFAULT, validation: DEFAULT, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(size:, validation:)
      end

      def before_render
        @input_options = input_options
      end

      def call
        if bound?
          render_bound_element(:range_field, bound_form, bound_attribute, @input_options)
        else
          tag.input(**@input_options, type: :range)
        end
      end

      private

      def input_options
        options = attributes_for(@options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end
    end
  end
end
