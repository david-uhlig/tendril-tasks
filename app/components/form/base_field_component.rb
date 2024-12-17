# frozen_string_literal: true

module Form
  # Base structure for form field components.
  #
  # It provides a consistent way to render fields with their associated label,
  # error messages, and custom options.
  #
  # Example Usage:
  #   <%= render Form::BaseFieldComponent.new(form, :email, "Email Address", class: "custom-class") do %>
  #     <%= form.text_field :email %>
  #   <% end %>
  class BaseFieldComponent < ApplicationComponent
    # @param form [Object] Form object (typically a `form_with` or `form_for` object) used for generating fields.
    # @param attribute [Symbol] The attribute from the model associated with the form field (e.g., :email).
    # @param label [String, nil, false] The label text for the field. Pass `nil` to use the default label, or `false` to omit the label entirely.
    # @param error_field_attribute [Symbol] (Optional) The attribute used for displaying error messages. Defaults to the `attribute` parameter if not provided.
    # @param options [Hash] (Optional) A hash of additional HTML options for the container div.
    #
    # The block passed to this component will be rendered as the actual field content (e.g., text field, checkbox, etc.).
    def initialize(form, attribute, label = nil, error_field_attribute = nil, **options)
      @form = form
      @attribute = attribute
      @error_field_attribute = error_field_attribute || attribute
      @label = label ||
        form.object.class.human_attribute_name(attribute).presence ||
        attribute.to_s.humanize
      @options = options
    end
  end
end
