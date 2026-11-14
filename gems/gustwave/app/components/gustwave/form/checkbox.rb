# frozen_string_literal: true

module Gustwave
  module Form
    # Use Checkbox to render Flowbite's checkbox: a square box for a yes or no
    # answer, or for one of several options, in seven colors.
    #
    # The checkbox is the +<input type="checkbox">+ itself, and +options+ are
    # its HTML attributes, e.g. +checked+, +disabled+, +name+, +value+ and
    # +required+. It renders no label: the text beside the box is the label of
    # a Gustwave::Form::InlineField. On its own, the checkbox gets its
    # accessible name from the caller:
    #
    #   <%= render Gustwave::Form::Checkbox.new(name: "task_ids[]", value: "7", aria: { label: "Select task" }) %>
    #
    # +color+ is an option. Flowbite's colors are +:blue+, +:red+, +:green+,
    # +:purple+, +:teal+, +:yellow+ and +:orange+. Flowbite shows the checkbox
    # in one size.
    #
    # === Without a form builder
    #
    # Renders a plain checkbox. +name+, +id+, +value+ and +checked+ are
    # ordinary HTML attributes.
    #
    # === With a form builder
    #
    # Pass the attribute and +form:+, a Rails form builder or any subclass.
    # Rails renders the element through its +check_box+ helper, so name, ID,
    # the record's value, +index+ and +namespace+ behave as in any Rails form,
    # and the hidden field that sends the unchecked value comes along, before
    # the checkbox. +checked_value+ and +unchecked_value+ are Rails' own,
    # +"1"+ and +"0"+ by default, and +include_hidden: false+ leaves the
    # hidden field out:
    #
    #   <%= render Gustwave::Form::Checkbox.new(:terms, form: f, aria: { label: "I accept the terms" }) %>
    #
    # Rails' +field_error_proc+ never wraps the checkbox. In the +error+
    # validation state the checkbox sets +aria-invalid="true"+, unless the
    # caller's +aria+ options say otherwise. Flowbite shows no validation look
    # for the checkbox, so the state changes no classes.
    #
    # === In a field
    #
    # Gustwave::Form::InlineField builds the checkbox, wires it through
    # +apply_slot_context+ (see there) and renders its label beside the box,
    # with the helper text under it:
    #
    #   <%= render Gustwave::Form::InlineField.new(:terms, form: f) do |field| %>
    #     <% field.with_control_checkbox %>
    #   <% end %>
    #
    # @status alpha
    class Checkbox < Gustwave::Component
      include Gustwave::Form::BoundControl

      # Flowbite's checkbox. It keeps these classes when it's disabled.
      base "w-4 h-4 bg-gray-100 border-gray-300 rounded-sm focus:ring-2 dark:ring-offset-gray-800 dark:bg-gray-700 dark:border-gray-600"

      # The color of the checked box and of the focus ring
      variant :color, default: :blue, values: {
        blue: "text-blue-600 focus:ring-blue-500 dark:focus:ring-blue-600",
        red: "text-red-600 focus:ring-red-500 dark:focus:ring-red-600",
        green: "text-green-600 focus:ring-green-500 dark:focus:ring-green-600",
        purple: "text-purple-600 focus:ring-purple-500 dark:focus:ring-purple-600",
        teal: "text-teal-600 focus:ring-teal-500 dark:focus:ring-teal-600",
        yellow: "text-yellow-400 focus:ring-yellow-500 dark:focus:ring-yellow-600",
        orange: "text-orange-500 focus:ring-orange-500 dark:focus:ring-orange-600"
      }

      # Flowbite shows no validation look for the checkbox, so the state only
      # sets +aria-invalid+.
      option :validation, default: :none, values: %i[none success error]

      # @param attribute [Symbol, String, nil] the attribute of the form's object the checkbox is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the checkbox is a plain +<input>+.
      # @param color [Symbol] the color of the checked box and of the focus ring. Defaults to +:blue+. Valid values are +:blue+, +:red+, +:green+, +:purple+, +:teal+, +:yellow+ and +:orange+.
      # @param validation [Symbol] the validation state. Defaults to +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ sets +aria-invalid+. The state has no look.
      # @param checked_value [Object] Rails' +check_box+ value of a checked box, only with +form+. Defaults to +"1"+.
      # @param unchecked_value [Object] Rails' +check_box+ value of an unchecked box, only with +form+. Defaults to +"0"+; +nil+ leaves out the hidden field.
      # @param include_hidden [Boolean] Rails' +include_hidden+ option: whether a bound checkbox renders the hidden field for the unchecked value. Defaults to +true+.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +name+, +id+, +value+, +checked+, +required+, +disabled+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, color: DEFAULT, validation: DEFAULT,
                     checked_value: DEFAULT, unchecked_value: DEFAULT, include_hidden: DEFAULT, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @checked_value = checked_value.equal?(DEFAULT) ? "1" : checked_value
        @unchecked_value = unchecked_value.equal?(DEFAULT) ? "0" : unchecked_value
        @include_hidden = include_hidden
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(color:, validation:)
      end

      def before_render
        @input_options = input_options
      end

      def call
        if bound?
          render_bound_element(:check_box, bound_form, bound_attribute, @input_options, @checked_value, @unchecked_value)
        else
          tag.input(**@input_options, type: :checkbox)
        end
      end

      # The ID the checkbox renders, for a field's label. With +multiple: true+
      # Rails appends the checked value to the ID of a bound checkbox, so
      # several checkboxes for one attribute don't share it.
      #
      # @return [String, nil] +nil+ for an unbound checkbox without an ID.
      def html_id
        return super unless bound? && explicit_id.nil? && @options[:multiple] && !@checked_value.nil?

        bound_form.field_id(bound_attribute, sanitized_value(@checked_value))
      end

      private

      def input_options
        options = attributes_for(@options)
        options[:id] = explicit_id if explicit_id
        options[:include_hidden] = @include_hidden if bound? && !@include_hidden.equal?(DEFAULT)
        merge_aria(options)
      end
    end
  end
end
