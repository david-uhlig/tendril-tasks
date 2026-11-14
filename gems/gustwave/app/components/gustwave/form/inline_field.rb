# frozen_string_literal: true

module Gustwave
  module Form
    # Use InlineField to render a form control with its label beside it, as
    # Flowbite does for a toggle, a checkbox and a radio button: the control
    # first, then a column with the label and the helper text under it. The
    # validation message follows below the row. Like Gustwave::Form::Field,
    # which stacks them, it ties the control to them: the label's +for+, the
    # control's +aria-describedby+ and +aria-invalid+, and the validation
    # state's colors. The root is a plain +<div>+ without classes of its own,
    # so spacing is up to the caller.
    #
    # +attribute+, +form:+, +label:+, +helper_text:+, +validation:+ and
    # +validation_message:+ work as in Gustwave::Form::Field, and so do the
    # slots of the same name.
    #
    # === Example
    #
    #   <%= render Gustwave::Form::InlineField.new(:published, form: f, helper_text: "Visible to everyone.") do |field| %>
    #     <% field.with_control_toggle(color: :green) %>
    #   <% end %>
    #
    # The block without a +control+ slot is the control, for an app's own
    # markup:
    #
    #   <%= render Gustwave::Form::InlineField.new(label: "Remember me") do %>
    #     <%= check_box_tag :remember_me %>
    #   <% end %>
    #
    # A disabled control's label isn't grayed by the field. Flowbite does that
    # in some examples only, so it's the label's class:
    # <tt>field.with_label("Sync", class: "text-gray-400 dark:text-gray-500")</tt>.
    #
    # @status alpha
    class InlineField < Gustwave::Component
      include Gustwave::Form::FieldWiring

      # The row with the control and the text column
      part :row, "flex"

      # The cell of the control, which centers it
      part :control_cell, "flex items-center"

      # The column beside the control, with the label and the helper text
      part :text, "text-sm"

      # The label, with the validation state's colors
      part :label, "font-medium"

      # The helper text under the label
      part :helper_text, "text-xs font-normal text-gray-500 dark:text-gray-300"

      # The validation message below the row. Without a validation state it
      # looks like the stacked field's helper text.
      part :validation_message, "mt-2 text-sm"

      variant :validation, default: :none, values: {
        none: {
          label: "text-gray-900 dark:text-gray-300",
          validation_message: "text-gray-500 dark:text-gray-400"
        },
        success: {
          label: "text-green-700 dark:text-green-500",
          validation_message: "text-green-600 dark:text-green-500"
        },
        error: {
          label: "text-red-700 dark:text-red-500",
          validation_message: "text-red-600 dark:text-red-500"
        }
      }

      # The space between the control and the text, which Flowbite sets per
      # control: +ms-3+ after a toggle, +ms-2+ after anything else. The field
      # picks it from the type of its control.
      variant :gap, part: :text, default: :sm, internal: true, values: {
        sm: "ms-2",
        md: "ms-3"
      }

      # The control of the field.
      #
      # * +toggle+: a Gustwave::Form::Toggle, built with the given arguments.
      # * +renderable+: any component. One that implements +apply_slot_context+
      #   receives +attribute+, +form+, +id+ (without a form), +validation+ and
      #   +described_by+, as Gustwave::Form::Toggle does.
      #
      #   <% field.with_control_toggle(size: :lg) %>
      #   <% field.with_control_renderable(MyCheckbox.new) %>
      renders_one_extensible :control, types: {
        toggle: ->(*args, **options) {
          select_options(gap: :md)
          Gustwave::Form::Toggle.new(*args, **options)
        }
      }, renderable: :control_context

      # @param attribute [Symbol, String, nil] the attribute of the form's object the field is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Passed to the control with the attribute.
      # @param label [String, Boolean, nil] the text of the label. Shorthand for the +label+ slot. By default a bound field renders the text of Rails' +label+ helper. +false+ or +nil+ renders no label.
      # @param helper_text [String, nil] shorthand for the +helper_text+ slot.
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+.
      # @param validation_message [String, nil] shorthand for the +validation_message+ slot. By default a bound field renders the attribute's error messages.
      # @param row_options [Hash] the HTML attributes of the row's +<div>+.
      # @param control_cell_options [Hash] the HTML attributes of the +<div>+ around the control.
      # @param text_options [Hash] the HTML attributes of the +<div>+ around the label and the helper text.
      # @param options [Hash] HTML attributes of the +<div>+.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, label: DEFAULT, helper_text: nil, validation: DEFAULT,
                     validation_message: nil, row_options: {}, control_cell_options: {}, text_options: {}, **options)
        @part_options = { row: row_options, control_cell: control_cell_options, text: text_options }
                        .transform_values { |part_options| (part_options || {}).to_h }
        super(attribute, form:, label:, helper_text:, validation:, validation_message:, **options)
      end

      def call
        tag.div(**@options) do
          safe_join([ row_element, validation_message_element ].compact)
        end
      end

      private

      def row_element
        tag.div(**attributes_for(:row, @part_options[:row])) do
          safe_join([
            tag.div(control_element, **attributes_for(:control_cell, @part_options[:control_cell])),
            text_element
          ].compact)
        end
      end

      def text_element
        elements = [ label_element, helper_text_element ].compact
        tag.div(safe_join(elements), **attributes_for(:text, @part_options[:text])) if elements.any?
      end
    end
  end
end
