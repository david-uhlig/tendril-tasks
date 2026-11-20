# frozen_string_literal: true

module Gustwave
  module Form
    # Use ValidationMessage to render the validation message of an attribute
    # on its own, where no single field can carry it: once for the radios or
    # the +multiple+ checkboxes of a group, which are one field each. A field
    # for a control of its own renders its message itself, see
    # Gustwave::Form::Field.
    #
    # With +form:+ it renders the attribute's error messages as a sentence, in
    # the +error+ state, under the ID a field gives its message:
    # <tt>field_id(:plan, :validation_message)</tt>. Without errors and
    # without a block it renders nothing.
    #
    #   <fieldset aria-describedby="<%= f.field_id(:plan, :validation_message) %>">
    #     <legend>Plan</legend>
    #     <%= f.radio_button :plan, "free" %>
    #     <%= f.radio_button :plan, "pro" %>
    #     <%= render Gustwave::Form::ValidationMessage.new(:plan, form: f) %>
    #   </fieldset>
    #
    # Gustwave::Form::Fieldset renders the same group with the wiring done.
    #
    # The block is the message, instead of the attribute's errors:
    #
    #   <%= render Gustwave::Form::ValidationMessage.new(id: "plan-message", validation: :error) do %>
    #     Choose a plan to continue.
    #   <% end %>
    #
    # @status alpha
    class ValidationMessage < Gustwave::Component
      part :root, "mt-2 text-sm"

      # The color of the message. Without a state it looks like a helper text.
      variant :validation, default: :none, values: {
        none: "text-gray-500 dark:text-gray-400",
        success: "text-green-600 dark:text-green-500",
        error: "text-red-600 dark:text-red-500"
      }

      # @param attribute [Symbol, String, nil] the attribute of the form's object the message is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass.
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+.
      # @param options [Hash] the HTML attributes of the +<p>+. A bound message takes its +id+ from Rails' +field_id+ unless one is given.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, validation: DEFAULT, **options)
        if attribute && form.nil?
          raise ArgumentError, "#{self.class.name} needs `form:` for the attribute #{attribute.inspect}. " \
                               "Without a form builder, pass the message as the block."
        end

        @attribute = attribute
        @form = form
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(validation:)
      end

      def before_render
        @error_sentence = Gustwave::Form::BoundControl.error_sentence(@form, @attribute)
        select_options(validation: :error) if !@validation_given && @error_sentence
        @text = content.presence || @error_sentence
      end

      def render? = @text.present?

      def call
        tag.p(@text, **attributes_for({ id: html_id }.compact.merge(@options)))
      end

      # The ID the message renders, for the +aria-describedby+ of its group.
      #
      # @return [String, nil] +nil+ for an unbound message without an ID.
      def html_id
        @options[:id].presence || (@form.field_id(@attribute, :validation_message) if @form && @attribute)
      end
    end
  end
end
