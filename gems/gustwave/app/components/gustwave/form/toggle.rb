# frozen_string_literal: true

module Gustwave
  module Form
    # Use Toggle to render a toggle: a checkbox shown as a switch for a yes or no
    # answer. Like every control, it renders on its own or bound to a form
    # builder, and Gustwave::Form::InlineField renders it with its label beside
    # the switch: see {file:README.md#Building_forms Building forms}.
    #
    #   <%= render Gustwave::Form::Toggle.new(name: "notifications", value: "1", aria: { label: "Enable notifications" }) %>
    #   <%= render Gustwave::Form::Toggle.new(:published, form: f, aria: { label: "Published" }) %>
    #
    # The +<input type="checkbox">+ is hidden and the switch is its +track+,
    # which is drawn from the input's state. A +<label>+ without text wraps the
    # two, so a click on the switch reaches the input. Bound, it renders through
    # Rails' +check_box+, so the hidden field that sends the unchecked value
    # comes along.
    #
    # @status alpha
    class Toggle < Gustwave::Component
      include Gustwave::Form::BoundControl

      # The checkbox itself, hidden, which the other parts follow with +peer+ classes
      part :input, "sr-only peer"

      # The +<label>+ around the checkbox and the switch, which makes the switch clickable
      part :label, "inline-flex items-center cursor-pointer"

      # The switch: the track and, as its +::after+, the knob
      part :track, "relative bg-gray-200 peer-focus:outline-none peer-focus:ring-4 rounded-full peer dark:bg-gray-700 " \
                   "peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full " \
                   "peer-checked:after:border-white after:content-[''] after:absolute after:bg-white " \
                   "after:border-gray-300 after:border after:rounded-full after:transition-all dark:border-gray-600"

      variant :size, default: :md, values: {
        sm: { track: "w-9 h-5 after:top-[2px] after:start-[2px] after:h-4 after:w-4" },
        md: { track: "w-11 h-6 after:top-[2px] after:start-[2px] after:h-5 after:w-5" },
        lg: { track: "w-14 h-7 after:top-0.5 after:start-[4px] after:h-6 after:w-6" }
      }

      variant :color, default: :blue, values: {
        blue: { track: "peer-focus:ring-blue-300 dark:peer-focus:ring-blue-800 peer-checked:bg-blue-600 dark:peer-checked:bg-blue-600" },
        red: { track: "peer-focus:ring-red-300 dark:peer-focus:ring-red-800 peer-checked:bg-red-600 dark:peer-checked:bg-red-600" },
        green: { track: "peer-focus:ring-green-300 dark:peer-focus:ring-green-800 peer-checked:bg-green-600 dark:peer-checked:bg-green-600" },
        purple: { track: "peer-focus:ring-purple-300 dark:peer-focus:ring-purple-800 peer-checked:bg-purple-600 dark:peer-checked:bg-purple-600" },
        yellow: { track: "peer-focus:ring-yellow-300 dark:peer-focus:ring-yellow-800 peer-checked:bg-yellow-400 dark:peer-checked:bg-yellow-400" },
        teal: { track: "peer-focus:ring-teal-300 dark:peer-focus:ring-teal-800 peer-checked:bg-teal-600 dark:peer-checked:bg-teal-600" },
        orange: { track: "peer-focus:ring-orange-300 dark:peer-focus:ring-orange-800 peer-checked:bg-orange-500 dark:peer-checked:bg-orange-500" }
      }

      # Flowbite shows no validation look for the toggle, so the state only
      # sets +aria-invalid+.
      option :validation, default: :none, values: %i[none success error]

      # @param attribute [Symbol, String, nil] the attribute of the form's object the toggle is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the toggle is a plain checkbox.
      # @param size [Symbol] the size of the toggle. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+. The HTML attribute +size+ goes in +html:+.
      # @param color [Symbol] the color of the switch when it is on and when it has focus. Defaults to +:blue+. Valid values are +:blue+, +:red+, +:green+, +:purple+, +:yellow+, +:teal+ and +:orange+.
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ sets +aria-invalid+, unless the caller's +aria+ options say otherwise. The state has no look.
      # @param checked_value [Object] Rails' +check_box+ value of a checked box, only with +form+. Defaults to +"1"+.
      # @param unchecked_value [Object] Rails' +check_box+ value of an unchecked box, only with +form+. Defaults to +"0"+; +nil+ leaves out the hidden field.
      # @param include_hidden [Boolean] Rails' +include_hidden+ option: whether a bound toggle renders the hidden field for the unchecked value. Defaults to +true+.
      # @param label_options [Hash] the HTML attributes of the +<label>+ around the toggle, e.g. +class+ for its margin.
      # @param track_options [Hash] the HTML attributes of the switch's +<div>+.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +name+, +id+, +value+, +checked+, +required+, +disabled+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, size: DEFAULT, color: DEFAULT, validation: DEFAULT,
                     checked_value: DEFAULT, unchecked_value: DEFAULT, include_hidden: DEFAULT,
                     label_options: {}, track_options: {}, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @checked_value = checked_value.equal?(DEFAULT) ? "1" : checked_value
        @unchecked_value = unchecked_value.equal?(DEFAULT) ? "0" : unchecked_value
        @include_hidden = include_hidden
        @part_options = { label: label_options, track: track_options }
                        .transform_values { |part_options| (part_options || {}).to_h }
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(size:, color:, validation:)
      end

      def before_render
        @input_options = input_options
      end

      def call
        tag.label(**attributes_for(:label, @part_options[:label])) do
          safe_join([ input_element, tag.div(**attributes_for(:track, @part_options[:track])) ])
        end
      end

      private

      def input_options
        options = attributes_for(:input, @options)
        options[:id] = explicit_id if explicit_id
        options[:include_hidden] = @include_hidden if bound? && !@include_hidden.equal?(DEFAULT)
        merge_aria(options)
      end

      def input_element
        if bound?
          render_bound_element(:check_box, bound_form, bound_attribute, @input_options, @checked_value, @unchecked_value)
        else
          tag.input(**@input_options, type: :checkbox)
        end
      end
    end
  end
end
