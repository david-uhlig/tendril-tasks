# frozen_string_literal: true

module Form
  # A Gustwave::Form::Toggle with the field's label and errors, and optional
  # texts around the switch: one shown before it and one after it. Both are
  # labels of the checkbox, so a click on them flips the switch.
  #
  # Example Usage:
  #   <%= render Form::ToggleComponent.new(f, :publish, "Visibility") do |toggle| %>
  #     <% toggle.with_checked_state_text("Private") %>
  #     <% toggle.with_unchecked_state_text("Public") %>
  #   <% end %>
  #
  # @todo Refactor to use dual sided toggle once Gustwave for Flowbite v4 is released
  class ToggleComponent < TendrilTasks::Component
    STATE_TEXT_CLASSES = "text-sm font-medium text-gray-900 dark:text-gray-300 cursor-pointer"

    renders_one :checked_state_text, ->(text, **options) do
      state_text_label(text, "me-3", options)
    end

    renders_one :unchecked_state_text, ->(text, **options) do
      state_text_label(text, "ms-3", options)
    end

    # @param form [Object] the form builder
    # @param attribute [Symbol] the boolean attribute
    # @param label [String, nil, false] +nil+ for the default label, +false+ for none, or the label's text
    # @param options [Hash] HTML attributes of the toggle's checkbox, e.g. +checked+
    def initialize(form, attribute, label = nil, **options)
      @form = form
      @attribute = attribute
      @label_option = label.nil? ? {} : { label: label }
      @options = options
    end

    def call
      render Gustwave::Form::Field.new(@attribute, form: @form, **@label_option) do |field|
        field.with_control_renderable(
          Row.new(Gustwave::Form::Toggle.new(**@options),
                  leading: (checked_state_text if checked_state_text?),
                  trailing: (unchecked_state_text if unchecked_state_text?))
        )
      end
    end

    private

    # A label for the checkbox, so a click on the text flips the switch.
    def state_text_label(text, margin, options)
      options = options.deep_symbolize_keys
      options[:class] = class_merge(margin, STATE_TEXT_CLASSES, options.delete(:class))
      tag.label(text, for: checkbox_id, **options)
    end

    def checkbox_id = @options[:id] || @form.field_id(@attribute)

    # The toggle with the state texts beside it, as the field's control. It
    # passes the field's wiring (binding, ID, validation state and
    # +aria-describedby+) on to the toggle.
    class Row < TendrilTasks::Component
      delegate :apply_slot_context, :html_id, :disabled?, to: :@toggle

      # @param toggle [Gustwave::Form::Toggle] the toggle
      # @param leading [String, nil] the text before the toggle
      # @param trailing [String, nil] the text after the toggle
      def initialize(toggle, leading: nil, trailing: nil)
        @toggle = toggle
        @leading = leading
        @trailing = trailing
      end

      def call
        tag.div(class: "inline-flex items-center") do
          safe_join([ @leading, render(@toggle), @trailing ].compact)
        end
      end
    end
    private_constant :Row
  end
end
