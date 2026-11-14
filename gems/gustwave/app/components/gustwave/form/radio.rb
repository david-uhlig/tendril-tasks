# frozen_string_literal: true

module Gustwave
  module Form
    # Use Radio to render Flowbite's radio button: a round button for one
    # choice out of several, in seven colors.
    #
    # The radio is the +<input type="radio">+ itself, and +options+ are its
    # HTML attributes, e.g. +value+, +checked+, +disabled+, +name+ and
    # +required+. It renders no label: the text beside the button is the label
    # of a Gustwave::Form::InlineField. On its own, the radio gets its
    # accessible name from the caller:
    #
    #   <%= render Gustwave::Form::Radio.new(name: "plan", value: "free", aria: { label: "Free plan" }) %>
    #
    # +color+ is an option. Flowbite's colors are +:blue+, +:red+, +:green+,
    # +:purple+, +:teal+, +:yellow+ and +:orange+. Flowbite shows the radio in
    # one size.
    #
    # === Without a form builder
    #
    # Renders a plain radio. +name+, +id+, +value+ and +checked+ are ordinary
    # HTML attributes.
    #
    # === With a form builder
    #
    # Pass the attribute, +form:+ (a Rails form builder or any subclass) and
    # the +value+ the radio stands for. Rails renders the element through its
    # +radio_button+ helper, so the name, the ID (+task_plan_free+), +index+
    # and +namespace+ behave as in any Rails form, and the radio is checked
    # when the record's value equals +value+. A +checked+ of the caller wins.
    # A bound radio needs a +value+:
    #
    #   <%= render Gustwave::Form::Radio.new(:plan, form: f, value: "free", aria: { label: "Free" }) %>
    #   <%= render Gustwave::Form::Radio.new(:plan, form: f, value: "pro", aria: { label: "Pro" }) %>
    #
    # Rails' +field_error_proc+ never wraps the radio. In the +error+
    # validation state the radio sets +aria-invalid="true"+, unless the
    # caller's +aria+ options say otherwise. Flowbite shows no validation look
    # for the radio, so the state changes no classes.
    #
    # === In a field
    #
    # Gustwave::Form::InlineField builds the radio, wires it through
    # +apply_slot_context+ (see there) and renders its label beside the
    # button, with the helper text under it. The radios of one group are
    # fields for one attribute:
    #
    #   <%= render Gustwave::Form::InlineField.new(:plan, form: f) do |field| %>
    #     <% field.with_control_radio(value: "free") %>
    #   <% end %>
    #   <%= render Gustwave::Form::InlineField.new(:plan, form: f) do |field| %>
    #     <% field.with_control_radio(value: "pro") %>
    #   <% end %>
    #
    # @status alpha
    class Radio < Gustwave::Component
      include Gustwave::Form::BoundControl

      # Flowbite's radio. It keeps these classes when it's disabled.
      base "w-4 h-4 bg-gray-100 border-gray-300 focus:ring-2 dark:ring-offset-gray-800 dark:bg-gray-700 dark:border-gray-600"

      # The color of the checked button and of the focus ring
      variant :color, default: :blue, values: {
        blue: "text-blue-600 focus:ring-blue-500 dark:focus:ring-blue-600",
        red: "text-red-600 focus:ring-red-500 dark:focus:ring-red-600",
        green: "text-green-600 focus:ring-green-500 dark:focus:ring-green-600",
        purple: "text-purple-600 focus:ring-purple-500 dark:focus:ring-purple-600",
        teal: "text-teal-600 focus:ring-teal-500 dark:focus:ring-teal-600",
        yellow: "text-yellow-400 focus:ring-yellow-500 dark:focus:ring-yellow-600",
        orange: "text-orange-500 focus:ring-orange-500 dark:focus:ring-orange-600"
      }

      # Flowbite shows no validation look for the radio, so the state only
      # sets +aria-invalid+.
      option :validation, default: :none, values: %i[none success error]

      # @param attribute [Symbol, String, nil] the attribute of the form's object the radio is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the radio is a plain +<input>+.
      # @param color [Symbol] the color of the checked button and of the focus ring. Defaults to +:blue+. Valid values are +:blue+, +:red+, +:green+, +:purple+, +:teal+, +:yellow+ and +:orange+.
      # @param validation [Symbol] the validation state. Defaults to +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ sets +aria-invalid+. The state has no look.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +value+, +name+, +id+, +checked+, +required+, +disabled+. A bound radio needs +value+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+, and when rendered bound without a +value+.
      def initialize(attribute = nil, form: nil, color: DEFAULT, validation: DEFAULT, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(color:, validation:)
      end

      def before_render
        if bound? && !@options.key?(:value)
          raise ArgumentError, "#{self.class.name} needs `value:` for the attribute #{bound_attribute.inspect}."
        end

        @input_options = input_options
      end

      def call
        if bound?
          render_bound_element(:radio_button, bound_form, bound_attribute, value, @input_options.except(:value))
        else
          tag.input(**@input_options, type: :radio)
        end
      end

      # The value the radio stands for.
      #
      # @return [Object, nil]
      def value = @options[:value]

      # The ID the radio renders, for a field's label. Rails appends the
      # value to the ID of a bound radio, so the radios of one group don't
      # share it.
      #
      # @return [String, nil] +nil+ for an unbound radio without an ID.
      def html_id
        return explicit_id if explicit_id
        return unless bound?

        bound_form.field_id(bound_attribute, sanitized_value(value))
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
