# frozen_string_literal: true

module Gustwave
  module Form
    # Lets a control render its element through a Rails form builder, so the
    # name, ID, value, type casting, nested attributes, +index+ and
    # +namespace+ behave as in any Rails form (D9 in docs/design.md).
    #
    # A control includes the concern, keeps its binding in a form builder and
    # an attribute, and hands its HTML attributes to +render_bound_element+:
    #
    #   class Textarea < Gustwave::Component
    #     include Gustwave::Form::BoundControl
    #
    #     def call
    #       render_bound_element(:text_area, @form, @attribute, @options)
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

      private

      # Renders the element with Rails' helper as defined on
      # ActionView::Helpers::FormBuilder.
      #
      # @param helper [Symbol] e.g. +:text_field+.
      # @param form [ActionView::Helpers::FormBuilder]
      # @param attribute [Symbol, String]
      # @param html_options [Hash] the element's HTML attributes.
      # @return [ActiveSupport::SafeBuffer]
      def render_bound_element(helper, form, attribute, html_options)
        ActionView::Helpers::FormBuilder.instance_method(helper)
                                        .bind_call(errorless_builder(form), attribute, html_options)
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
