# frozen_string_literal: true

module Gustwave
  module Form
    # Use Fieldset to render a group of fields for one attribute, like the
    # radios of a choice or the checkboxes of a +multiple+ attribute, with
    # what belongs to the group as a whole: the +<legend>+, the
    # validation message and a helper text, rendered once, in this order
    # below the group. The +<fieldset>+ names the message and the helper text
    # in +aria-describedby+, so they're announced with the group. The root has no classes of its own, so spacing is up to the
    # caller.
    #
    # The block is the group: one field per control, or any markup. The
    # fields keep the validation state. They leave the attribute's error
    # messages to the fieldset, see Gustwave::Form::FieldWiring.
    #
    #   <%= render Gustwave::Form::Fieldset.new(:tag_ids, form: f, helper_text: "Pick any.") do %>
    #     <% @tags.each do |tag| %>
    #       <%= f.check_box :tag_ids, { multiple: true, label: tag.name }, tag.id, nil %>
    #     <% end %>
    #   <% end %>
    #
    # +attribute+, +form:+, +label:+, +helper_text:+, +validation:+ and
    # +validation_message:+ work as in Gustwave::Form::Field, and so do the
    # slots of the same name. The label is the +<legend>+, so a legend only
    # for screen readers is <tt>fieldset.with_label("Plan", class: "sr-only")</tt>.
    #
    # Without +form:+ it renders only what the caller sets.
    #
    # @status alpha
    class Fieldset < Gustwave::Component
      include Gustwave::Form::FieldWiring

      # The legend, with the validation state's colors
      part :label, "mb-2 text-sm font-medium"

      # The helper text below the group, after the validation message
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

      def call
        tag.fieldset(**fieldset_options) do
          safe_join([ legend_element, content, validation_message_element, helper_text_element ].compact)
        end
      end

      private

      # The message and the helper text, in the order they're rendered. Fields
      # list the helper text first, see FieldWiring.
      def described_by
        [ validation_message_id, helper_text_id ].compact.join(" ").presence
      end

      # The caller's HTML attributes, with the message and the helper text
      # added to +aria-describedby+.
      def fieldset_options
        options = attributes_for(@options)
        aria = (options[:aria] || {}).to_h.symbolize_keys
        described = [ aria[:describedby] || options.delete(:"aria-describedby"), described_by ].compact_blank.join(" ")
        aria[:describedby] = described if described.present?
        aria.empty? ? options : options.merge(aria:)
      end

      def legend_element
        return unless @label_content

        tag.legend(@label_content.text, **attributes_for(:label, @label_content.options))
      end
    end
  end
end
