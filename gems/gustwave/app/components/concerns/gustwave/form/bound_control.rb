# frozen_string_literal: true

module Gustwave
  module Form
    # What every form control shares: the binding to a Rails form builder and
    # the wiring a parent such as Gustwave::Form::Field does.
    #
    # *Binding.* A control renders its element through a Rails form builder,
    # so the name, ID, value, type casting, nested attributes, +index+ and
    # +namespace+ behave as in any Rails form (D9 in docs/design.md).
    #
    # *Wiring.* It implements +apply_slot_context+, +html_id+ and +disabled?+,
    # so a field can bind the control, give it its ID and validation state,
    # list the IDs of the helper text and message in +aria-describedby+, and
    # gray its label along with a disabled control.
    #
    # *Looks.* It holds the classes of the validation states and of a
    # disabled control, so every control looks alike (+VALIDATION_LOOK+ and
    # +DISABLED_LOOK+).
    #
    # A control includes the concern, keeps its HTML attributes in +@options+
    # and declares the +validation+ variant and the +disabled_look+ toggle
    # with the constants, on its own part. Its constructor checks the binding
    # with +require_form_for_attribute+, keeps +@attribute+ and +@form+, and
    # sets +@validation_given+ to whether the caller picked a validation. It
    # hands its HTML attributes to +render_bound_element+:
    #
    #   class Textarea < Gustwave::Component
    #     include Gustwave::Form::BoundControl
    #
    #     part :textarea
    #     variant :validation, part: :textarea, default: :none, values: VALIDATION_LOOK
    #     toggle :disabled_look, part: :textarea, per: :validation, internal: true, values: DISABLED_LOOK
    #
    #     def initialize(attribute = nil, form: nil, validation: DEFAULT, **options)
    #       require_form_for_attribute(attribute, form)
    #       @attribute = attribute
    #       @form = form
    #       @options = options
    #       @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
    #       select_options(validation:)
    #     end
    #
    #     def call
    #       render_bound_element(:textarea, bound_form, bound_attribute, attributes_for(:textarea, @options))
    #     end
    #   end
    #
    # It calls Rails' own helper, not the one of the builder, because
    # Gustwave::FormBuilder overrides the helpers to render the components.
    # It renders through a builder around a stand-in for the record without
    # errors, so Rails never wraps the element in +field_error_proc+
    # (<tt><div class="field_with_errors"></tt>), which would break Flowbite's
    # markup, and the app's global proc stays as it is. The control marks the
    # error state itself.
    module BoundControl
      # The classes of the validation states, as Flowbite's input field has
      # them. The other controls follow the input field.
      VALIDATION_LOOK = {
        none: "bg-gray-50 border-gray-300 text-gray-900 focus:ring-blue-500 focus:border-blue-500 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500",
        success: "bg-green-50 border-green-500 text-green-900 dark:text-green-400 placeholder-green-700 dark:placeholder-green-500 focus:ring-green-500 focus:border-green-500 dark:border-green-500",
        error: "bg-red-50 border-red-500 text-red-900 placeholder-red-700 focus:ring-red-500 focus:border-red-500 dark:text-red-500 dark:placeholder-red-500 dark:border-red-500"
      }.freeze

      # The classes added to a disabled control, per validation state, as
      # Flowbite's disabled input has them.
      DISABLED_LOOK = {
        none: "bg-gray-100 cursor-not-allowed dark:text-gray-400",
        success: "cursor-not-allowed",
        error: "cursor-not-allowed"
      }.freeze

      # A stand-in for a record that reports no errors, so Rails' helpers
      # render the bare element. Everything else goes to the record.
      class ErrorlessObject < SimpleDelegator
        def errors = {}

        # Rails derives names and translations from the record's class.
        def class = __getobj__.class
      end

      # The error messages of +attribute+ on the object of +form+, and for a
      # +name_id+ attribute those of +name+, where +belongs_to+ puts them.
      #
      # @param form [ActionView::Helpers::FormBuilder, nil]
      # @param attribute [Symbol, String, nil]
      # @return [Array<String>] empty without a form, an object or errors.
      def self.error_messages(form, attribute)
        object = form&.object
        return [] if attribute.nil? || !object.respond_to?(:errors)

        errors = object.errors
        return [] unless errors.respond_to?(:[])

        names = [ attribute.to_s ]
        names << attribute.to_s.delete_suffix("_id") if attribute.to_s.end_with?("_id")
        names.flat_map { |name| Array(errors[name.to_sym]) }.uniq
      end

      # Lets a parent bind and wire the control, as Gustwave::Form::Field does.
      # What the caller gave the control itself wins over the context: its own
      # +form+ and attribute, an explicit +validation+ and its own +id+. The
      # parent may add keys later, so unknown ones are accepted.
      #
      # @param attribute [Symbol, String, nil] the attribute to bind to.
      # @param form [ActionView::Helpers::FormBuilder, nil] the form builder to bind to.
      # @param id [String, nil] the ID of a control without a form.
      # @param validation [Symbol, nil] the validation state, unless the caller picked one.
      # @param described_by [String, nil] IDs of the elements describing the control, merged with the caller's +aria-describedby+.
      def apply_slot_context(attribute: nil, form: nil, id: nil, validation: nil, described_by: nil, **)
        @context_attribute = attribute
        @context_form = form
        @context_id = id.presence
        @described_by = described_by.presence
        select_options(validation:) if validation && !@validation_given
      end

      # The ID the control renders: the caller's own, one from the context, or
      # Rails' ID for the bound attribute.
      #
      # @return [String, nil] +nil+ for an unbound control without an ID.
      def html_id
        explicit_id || (bound_form.field_id(bound_attribute) if bound?)
      end

      # Whether the control is disabled, for a field that shows it on the label.
      #
      # @return [Boolean]
      def disabled? = @options[:disabled].present?

      private

      # Raises for an attribute without a form builder, with the name of the
      # control's class in the message.
      #
      # @raise [ArgumentError]
      def require_form_for_attribute(attribute, form)
        return unless attribute && form.nil?

        raise ArgumentError, "#{self.class.name} needs `form:` for the attribute #{attribute.inspect}. " \
                             "Without a form builder, pass name:, id: and value: as HTML attributes instead."
      end

      def bound_form = @form || @context_form

      def bound_attribute = @attribute || @context_attribute

      def bound? = bound_form.present? && bound_attribute.present?

      # An ID Rails mustn't work out itself. It would add the namespace to a
      # bound ID again.
      def explicit_id = @options[:id].presence || @context_id

      # +aria-invalid+ in the error state and +aria-describedby+ from the
      # context, next to the caller's own +aria+ attributes, which win.
      def merge_aria(options)
        aria = (options[:aria] || {}).to_h.symbolize_keys
        flat_invalid = options.key?(:"aria-invalid")
        flat_describedby = options.delete(:"aria-describedby")
        aria[:invalid] = true if option_value(:validation) == :error && !aria.key?(:invalid) && !flat_invalid
        described = [ aria[:describedby] || flat_describedby, @described_by ].compact_blank.join(" ")
        aria[:describedby] = described if described.present?
        aria.empty? ? options : options.merge(aria:)
      end

      # Renders the element with Rails' helper as defined on
      # ActionView::Helpers::FormBuilder.
      #
      # @param helper [Symbol] e.g. +:text_field+.
      # @param form [ActionView::Helpers::FormBuilder]
      # @param attribute [Symbol, String]
      # @param args the arguments of Rails' helper after the attribute, e.g. the HTML attributes, or for +:select+ the choices, the options and the HTML attributes.
      # @yield passed on to the helper.
      # @return [ActiveSupport::SafeBuffer]
      def render_bound_element(helper, form, attribute, *args, &block)
        ActionView::Helpers::FormBuilder.instance_method(helper)
                                        .bind_call(errorless_builder(form), attribute, *args, &block)
      end

      # A builder of the form's class for a record without errors. A form
      # without a record has no errors to hide, so it stays as it is.
      def errorless_builder(form)
        return form if form.object.nil?

        form.class.new(form.object_name, ErrorlessObject.new(form.object), helpers, form.options)
      end
    end
  end
end
