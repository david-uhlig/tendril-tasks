# frozen_string_literal: true

module Gustwave
  module Form
    # Use Radio to render a radio button: a round button for one choice out of
    # several. It has one size. Like every control, it renders on its own or
    # bound to a form builder, and Gustwave::Form::InlineField renders it with
    # its label beside the button: see {file:README.md#Building_forms Building forms}.
    #
    #   <%= render Gustwave::Form::Radio.new(name: "plan", value: "free", aria: { label: "Free plan" }) %>
    #   <%= render Gustwave::Form::Radio.new(:plan, form: f, value: "free", aria: { label: "Free" }) %>
    #
    # Bound, it needs the +value+ it stands for: Rails' +radio_button+ derives
    # the ID from it (+task_plan_free+) and checks the radio when the record's
    # value equals it. A +checked+ of the caller wins. The radios of a group are
    # one field each, in a Gustwave::Form::Fieldset.
    #
    # @status alpha
    class Radio < Gustwave::Component
      include Gustwave::Form::BoundControl

      # Flowbite's radio. It keeps these classes when it's disabled.
      part :root, "w-4 h-4 bg-gray-100 border-gray-300 focus:ring-2 dark:ring-offset-gray-800 dark:bg-gray-700 dark:border-gray-600"

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
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ sets +aria-invalid+, unless the caller's +aria+ options say otherwise. The state has no look.
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

      # A radio is always one of several for its attribute. Its field then
      # leaves the attribute's error messages to the group, see
      # Gustwave::Form::FieldWiring.
      #
      # @return [Boolean]
      def shares_attribute? = true

      # The ID the radio renders, for a field's label. Rails appends the
      # value to the ID of a bound radio, so the radios of one group don't
      # share it.
      #
      # @return [String, nil] +nil+ for an unbound radio without an ID.
      def html_id
        return explicit_id if explicit_id
        return unless bound?
        # Rails leaves the value out of the ID of a radio whose value is nil
        return bound_form.field_id(bound_attribute) if value.nil?

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
