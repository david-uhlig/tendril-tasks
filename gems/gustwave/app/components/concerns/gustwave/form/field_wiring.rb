# frozen_string_literal: true

module Gustwave
  module Form
    # What every field shares: the +label+, +helper_text+ and
    # +validation_message+ slots with their shorthand keywords, a bound
    # field's defaults, the validation state, and the wiring of the control,
    # which gets its binding, ID, validation state and +aria-describedby+
    # through +apply_slot_context+ (D9 in docs/design.md).
    #
    # There is one field class per label layout: Gustwave::Form::Field stacks
    # the label, the control and the texts, Gustwave::Form::InlineField puts
    # the label beside the control. A field class includes the concern,
    # declares the +label+, +helper_text+ and +validation_message+ parts, the
    # +validation+ variant and its polymorphic +control+ slot with
    # <tt>renderable: :control_context</tt>, and arranges the elements in
    # +call+ from +label_element+, +control_element+, +helper_text_element+
    # and +validation_message_element+.
    module FieldWiring
      extend ActiveSupport::Concern

      # The text and HTML attributes a slot was set with, rendered once the
      # field knows the IDs.
      Content = Struct.new(:text, :options)

      included do
        # The label. Takes text or a block, and HTML attributes. Its +for+ is
        # set to the control's ID.
        #
        #   <% field.with_label("Task title") %>
        renders_one_extensible :label, ->(text = nil, **options, &block) {
          @label_content = Content.new(text || block&.call, options)
          nil
        }

        # The helper text below the control. Takes text or a block, e.g. with a
        # link, and HTML attributes. The control's +aria-describedby+ lists it.
        #
        #   <% field.with_helper_text { "Read our #{link_to("Privacy Policy", "#")}.".html_safe } %>
        renders_one_extensible :helper_text, ->(text = nil, **options, &block) {
          @helper_text_content = Content.new(text || block&.call, options)
          nil
        }

        # The validation message below the control, in the color of the
        # validation state. Takes text or a block, e.g. with a bold lead-in, and
        # HTML attributes. The control's +aria-describedby+ lists it.
        #
        #   <% field.with_validation_message("Can't be blank.") %>
        renders_one_extensible :validation_message, ->(text = nil, **options, &block) {
          @validation_message_content = Content.new(text || block&.call, options)
          nil
        }
      end

      # @param attribute [Symbol, String, nil] the attribute of the form's object the field is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Passed to the control with the attribute.
      # @param label [String, Boolean, nil] the text of the label. Shorthand for the +label+ slot. By default a bound field renders the text of Rails' +label+ helper. +false+ or +nil+ renders no label.
      # @param helper_text [String, nil] shorthand for the +helper_text+ slot.
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+.
      # @param validation_message [String, nil] shorthand for the +validation_message+ slot. By default a bound field renders the attribute's error messages.
      # @param options [Hash] HTML attributes of the +<div>+.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, label: Gustwave::Options::DEFAULT, helper_text: nil, validation: Gustwave::Options::DEFAULT,
                     validation_message: nil, **options)
        if attribute && form.nil?
          raise ArgumentError, "#{self.class.name} needs `form:` for the attribute #{attribute.inspect}. " \
                               "Without a form builder, set the label and the control yourself."
        end

        @attribute = attribute
        @form = form
        @label = label
        @helper_text = helper_text
        @validation_message = validation_message
        @options = options
        @control_id = generate_random_id(prefix: "field")
        @validation_given = !validation.nil? && !validation.equal?(Gustwave::Options::DEFAULT)
        select_options(validation:)
      end

      def before_render
        select_options(validation: :error) if !@validation_given && error_messages.any?
        content # evaluates the block, so slots set in it are known below

        @label_content ||= keyword_label
        @helper_text_content ||= Content.new(@helper_text, {}) if @helper_text.present?
        @validation_message_content ||= keyword_validation_message

        wire_control
      end

      private

      def bound? = @form.present? && @attribute.present?

      def error_messages
        @error_messages ||= Gustwave::Form::BoundControl.error_messages(@form, @attribute)
      end

      # Passed to a renderable control when it's set. The helper text and
      # message may not be set yet, so +described_by+ follows in +wire_control+.
      def control_context
        { attribute: @attribute, form: @form, id: (@control_id unless bound?), validation: option_value(:validation) }
      end

      def keyword_label
        if @label.equal?(Gustwave::Options::DEFAULT)
          text = default_label_text if bound?
        else
          text = @label.presence if @label
        end
        Content.new(text, {}) if text.present?
      end

      # The text Rails' +label+ helper would render, from a translation or
      # the humanized attribute.
      def default_label_text
        text = nil
        @form.label(@attribute) { |builder| text = builder.translation; "" }
        text
      end

      def keyword_validation_message
        text = @validation_message.presence || error_sentence
        Content.new(text, {}) if text.present?
      end

      def error_sentence
        error_messages.to_sentence.upcase_first.presence
      end

      # Ties the control to the field: binding, ID, validation state and the
      # IDs of the helper text and message that are rendered.
      def wire_control
        explicit = control.html_id.presence if control.respond_to?(:html_id)
        @control_id = explicit || (@form.field_id(@attribute) if bound?) || @control_id

        if control.respond_to?(:apply_slot_context)
          described_by = [ helper_text_id, validation_message_id ].compact.join(" ").presence
          control.apply_slot_context(slot: :control, **control_context, described_by:)
        end

        @label_for = control ? (control.html_id.presence if control.respond_to?(:html_id)) || @control_id : (@control_id if bound?)
      end

      def helper_text_id
        return unless @helper_text_content

        @helper_text_content.options[:id] || (bound? ? @form.field_id(@attribute, :helper_text) : "#{@control_id}-helper-text")
      end

      def validation_message_id
        return unless @validation_message_content

        @validation_message_content.options[:id] ||
          (bound? ? @form.field_id(@attribute, :validation_message) : "#{@control_id}-validation-message")
      end

      def label_element
        return unless @label_content

        options = attributes_for(:label, { for: @label_for.presence }.compact.merge(@label_content.options))
        tag.label(@label_content.text, **options)
      end

      def control_element
        control || content.presence
      end

      def helper_text_element
        return unless @helper_text_content

        options = attributes_for(:helper_text, { id: helper_text_id }.merge(@helper_text_content.options))
        tag.p(@helper_text_content.text, **options)
      end

      def validation_message_element
        return unless @validation_message_content

        options = attributes_for(:validation_message,
                                 { id: validation_message_id }.merge(@validation_message_content.options))
        tag.p(@validation_message_content.text, **options)
      end
    end
  end
end
