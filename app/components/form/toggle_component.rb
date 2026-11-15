# frozen_string_literal: true

module Form
  # A Gustwave::Form::Toggle with the field's label and errors, and optional
  # texts around the switch: one shown before it and one after it.
  #
  # Example Usage:
  #   <%= render Form::ToggleComponent.new(f, :publish, "Visibility") do |toggle| %>
  #     <% toggle.with_checked_state_text("Private") %>
  #     <% toggle.with_unchecked_state_text("Public") %>
  #   <% end %>
  class ToggleComponent < TendrilTasks::Component
    STATE_TEXT_CLASSES = "text-sm font-medium text-gray-900 dark:text-gray-300"

    renders_one :checked_state_text, ->(text, **options) do
      options.deep_symbolize_keys!
      options[:class] = class_merge("me-3", STATE_TEXT_CLASSES, options.delete(:class))
      tag.span(text, **options)
    end

    renders_one :unchecked_state_text, ->(text, **options) do
      options.deep_symbolize_keys!
      options[:class] = class_merge("ms-3", STATE_TEXT_CLASSES, options.delete(:class))
      tag.span(text, **options)
    end

    # @param form [Object] the form builder
    # @param attribute [Symbol] the boolean attribute
    # @param label [String, nil, false] as for Form::BaseFieldComponent
    # @param options [Hash] HTML attributes of the toggle's checkbox, e.g. +checked+
    def initialize(form, attribute, label = nil, **options)
      @form = form
      @attribute = attribute
      @label = label
      @options = options
    end
  end
end
