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
    # *Validation.* A bound control defaults to the +:error+ state while its
    # attribute has errors, as Gustwave::Form::Field and
    # Gustwave::Form::ValidationMessage do, so it sets +aria-invalid+ also on
    # its own. The control's own +validation+ wins, then the state a parent
    # passes through +apply_slot_context+, then the attribute's errors (D17
    # in docs/design.md). The default is picked before the control's own
    # +before_render+, once the context is known.
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
    #     variant :validation, default: :none, values: VALIDATION_LOOK.transform_values { |look| { textarea: look } }
    #     toggle :disabled_look, per: :validation, internal: true,
    #            values: DISABLED_LOOK.transform_values { |look| { textarea: look } }
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
      # Picks the default validation state before the control's own
      # +before_render+, which may read it. BoundControl prepends it to every
      # class that includes it.
      module DefaultValidation
        # Selects +:error+ for a bound control whose attribute has errors,
        # unless the caller or a parent picked a state, then runs the
        # control's own +before_render+.
        #
        # @return [void]
        def before_render
          select_default_validation
          super
        end
      end

      # Prepends DefaultValidation, so the default comes before the
      # control's own +before_render+.
      #
      # @param base [Class] the control.
      # @return [void]
      def self.included(base)
        super
        base.prepend(DefaultValidation)
      end

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

      # The classes of a control joined to the addons of a
      # Gustwave::Form::InputGroup, per attached edge: +:start+ for a leading
      # addon, +:end+ for a trailing one, +:both+ for both. The control drops
      # the rounding of the attached corners and fills the row.
      JOINED_LOOK = {
        start: "rounded-none rounded-e-lg flex-1 min-w-0",
        end: "rounded-none rounded-s-lg flex-1 min-w-0",
        both: "rounded-none flex-1 min-w-0"
      }.freeze

      # A stand-in for a record that reports no errors, so Rails' helpers
      # render the bare element. Everything else goes to the record.
      class ErrorlessObject < SimpleDelegator
        # The errors of the record, always empty, so the helper shows no error state.
        #
        # @return [Hash] an empty hash.
        def errors = {}

        # Rails derives names and translations from the record's class.
        #
        # @return [Class] the class of the record.
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

      # The error messages of +attribute+ as one sentence, as a field and
      # Gustwave::Form::ValidationMessage render them.
      #
      # @param form [ActionView::Helpers::FormBuilder, nil]
      # @param attribute [Symbol, String, nil]
      # @return [String, nil] +nil+ without errors.
      def self.error_sentence(form, attribute)
        error_messages(form, attribute).to_sentence.upcase_first.presence
      end

      # Lets a parent bind and wire the control, as Gustwave::Form::Field does.
      # What the caller gave the control itself wins over the context: its own
      # +form+ and attribute, an explicit +validation+ and its own +id+. A
      # +validation+ from the context wins over the attribute's errors. The
      # parent may add keys later, so unknown ones are accepted.
      #
      # @param attribute [Symbol, String, nil] the attribute to bind to.
      # @param form [ActionView::Helpers::FormBuilder, nil] the form builder to bind to.
      # @param id [String, nil] the ID of a control without a form.
      # @param validation [Symbol, nil] the validation state, unless the caller picked one.
      # @param described_by [String, nil] IDs of the elements describing the control, merged with the caller's +aria-describedby+.
      # @param joined [Symbol, nil] the edges attached to addons, for a control with the +joined+ variant, set by Gustwave::Form::InputGroup.
      # @param size [Symbol, nil] the size, for a control with a +size+ option, unless the caller picked one. Set by Gustwave::Form::InputGroup.
      # @return [void]
      def apply_slot_context(attribute: nil, form: nil, id: nil, validation: nil, described_by: nil, joined: nil, size: nil, **)
        @context_attribute = attribute
        @context_form = form
        @context_id = id.presence
        @described_by = described_by.presence
        select_options(joined:) if joined && self.class.option_definition.option(:joined)
        select_options(size:) if size && !@size_given && self.class.option_definition.option(:size)
        return unless validation && !@validation_given

        @context_validation_given = true
        select_options(validation:)
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

      # +:error+ while the bound attribute has errors, unless the caller or
      # the context picked a state.
      def select_default_validation
        return if @validation_given || @context_validation_given || !bound?
        return if BoundControl.error_messages(bound_form, bound_attribute).empty?

        select_options(validation: :error)
      end

      # A value as Rails writes it into an ID, e.g. of a radio button or of a
      # +multiple+ checkbox.
      def sanitized_value(value)
        value.to_s.gsub(/[\s.]/, "_").gsub(/[^-[[:word:]]]/, "").downcase
      end

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
