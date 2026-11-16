# frozen_string_literal: true

module Gustwave
  module Form
    # Use Field to render a form control with its label, helper text and
    # validation message stacked around it, and to tie them together: the
    # label's +for+, the control's +aria-describedby+ and +aria-invalid+, and
    # the validation state's colors. The root is a plain +<div>+ without classes of its own,
    # so spacing is up to the caller.
    #
    # With +form:+, Rails' form builder or any subclass, the field is bound to
    # an attribute. It then renders the label Rails' +label+ helper would,
    # takes its IDs from +field_id+ and shows the attribute's errors. Without
    # +form:+ it renders only what the caller sets and generates the IDs.
    #
    # === Example
    #
    #   <%= render Gustwave::Form::Field.new(:title, form: f, helper_text: "Shown in the task list.") do |field| %>
    #     <% field.with_control_input(size: :lg) %>
    #   <% end %>
    #
    # The block without a +control+ slot is the control, for an app's own
    # markup:
    #
    #   <%= render Gustwave::Form::Field.new(label: "Plan", helper_text: "Pick one.") do %>
    #     <%= select_tag :plan, options_for_select(%w[Free Pro]) %>
    #   <% end %>
    #
    # === Validation
    #
    # The field holds the state and passes it to its control. A +name_id+
    # attribute takes the errors of +name+ too, e.g. +author_id+ those of
    # +author+. A bound field shows the error messages as a sentence, in a
    # Gustwave::Form::ValidationMessage: style it with the slot's HTML
    # attributes. For a control that is one of several for the attribute, see
    # Gustwave::Form::Fieldset.
    #
    # A checkbox, radio button or toggle has its label beside it: see
    # Gustwave::Form::InlineField.
    #
    # @status alpha
    class Field < Gustwave::Component
      include Gustwave::Form::FieldWiring

      # The label, with the validation state's colors
      part :label, "block mb-2 text-sm font-medium"

      # The helper text below the control
      part :helper_text, "mt-2 text-sm text-gray-500 dark:text-gray-400"

      variant :validation, default: :none, values: {
        none: {
          label: "text-gray-900 dark:text-white"
        },
        success: {
          label: "text-green-700 dark:text-green-500"
        },
        error: {
          label: "text-red-700 dark:text-red-500"
        }
      }

      # The control of the field.
      #
      # * +input+: a Gustwave::Form::Input, built with the given arguments.
      # * +textarea+: a Gustwave::Form::Textarea, built with the given arguments.
      # * +select+: a Gustwave::Form::Select, built with the given arguments.
      # * +rich_textarea+: a Gustwave::Form::RichTextarea, built with the given arguments.
      # * +file_input+: a Gustwave::Form::FileInput, built with the given arguments.
      # * +renderable+: any component. One that implements +apply_slot_context+
      #   receives +attribute+, +form+, +id+ (without a form), +validation+ and
      #   +described_by+, as Gustwave::Form::Input does.
      #
      #   <% field.with_control_input(type: :email, icon: :envelope) %>
      #   <% field.with_control_textarea(rows: 4) %>
      #   <% field.with_control_select(choices: @countries, prompt: "Choose a country") %>
      #   <% field.with_control_rich_textarea %>
      #   <% field.with_control_file_input(accept: "image/*") %>
      #   <% field.with_control_renderable(MyRating.new) %>
      renders_one_extensible :control, types: {
        input: ->(*args, **options) { Gustwave::Form::Input.new(*args, **options) },
        textarea: ->(*args, **options) { Gustwave::Form::Textarea.new(*args, **options) },
        select: ->(*args, **options) { Gustwave::Form::Select.new(*args, **options) },
        rich_textarea: ->(*args, **options) { Gustwave::Form::RichTextarea.new(*args, **options) },
        file_input: ->(*args, **options) { Gustwave::Form::FileInput.new(*args, **options) }
      }, renderable: :control_context

      def call
        tag.div(**@options) do
          safe_join([ label_element, control_element, helper_text_element, validation_message_element ].compact)
        end
      end
    end
  end
end
