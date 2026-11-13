# frozen_string_literal: true

module Gustwave
  module Form
    # Use Field to render a form control with its label, helper text and
    # validation message, and to tie them together: the label's +for+, the
    # control's +aria-describedby+ and +aria-invalid+, and the validation
    # state's colors. The root is a plain +<div>+ without classes of its own,
    # so spacing is up to the caller.
    #
    # With +form:+, Rails' form builder or any subclass, the field is bound to
    # an attribute. It then renders the label Rails' +label+ helper would,
    # takes its IDs from +field_id+ and shows the attribute's errors. Without
    # +form:+ it renders only what the caller sets and generates the IDs.
    #
    # +label:+, +helper_text:+ and +validation_message:+ are shorthand for the
    # slots of the same name.
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
    # The field holds the state. The caller's +validation+ wins, otherwise
    # it's +:error+ while the bound attribute has errors, or the attribute of
    # a +name_id+ attribute's +name+, and +:none+ otherwise. It passes the
    # state to its control. Without a +validation_message+, a bound field
    # shows the attribute's error messages as a sentence.
    #
    # @status alpha
    class Field < Gustwave::Component
      # The text and HTML attributes a slot was set with, rendered once the
      # field knows the IDs.
      Content = Struct.new(:text, :options)
      private_constant :Content

      # The label, with the validation state's colors
      part :label, "block mb-2 text-sm font-medium"

      # The helper text below the control
      part :helper_text, "mt-2 text-sm text-gray-500 dark:text-gray-400"

      # The validation message below the control. Without a validation state
      # it looks like the helper text.
      part :validation_message, "mt-2 text-sm"

      variant :validation, default: :none, values: {
        none: {
          label: "text-gray-900 dark:text-white",
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

      # The control of the field.
      #
      # * +input+: a Gustwave::Form::Input, built with the given arguments.
      # * +textarea+: a Gustwave::Form::Textarea, built with the given arguments.
      # * +select+: a Gustwave::Form::Select, built with the given arguments.
      # * +renderable+: any component. One that implements +apply_slot_context+
      #   receives +attribute+, +form+, +id+ (without a form), +validation+ and
      #   +described_by+, as Gustwave::Form::Input does.
      #
      #   <% field.with_control_input(type: :email, icon: :envelope) %>
      #   <% field.with_control_textarea(rows: 4) %>
      #   <% field.with_control_select(choices: @countries, prompt: "Choose a country") %>
      #   <% field.with_control_renderable(MyToggle.new) %>
      renders_one_extensible :control, types: {
        input: ->(*args, **options) { Gustwave::Form::Input.new(*args, **options) },
        textarea: ->(*args, **options) { Gustwave::Form::Textarea.new(*args, **options) },
        select: ->(*args, **options) { Gustwave::Form::Select.new(*args, **options) }
      }, renderable: :control_context

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

      # @param attribute [Symbol, String, nil] the attribute of the form's object the field is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Passed to the control with the attribute.
      # @param label [String, Boolean, nil] the text of the label. Shorthand for the +label+ slot. By default a bound field renders the text of Rails' +label+ helper. +false+ or +nil+ renders no label.
      # @param helper_text [String, nil] shorthand for the +helper_text+ slot.
      # @param validation [Symbol] the validation state. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+.
      # @param validation_message [String, nil] shorthand for the +validation_message+ slot. By default a bound field renders the attribute's error messages.
      # @param options [Hash] HTML attributes of the +<div>+.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, label: DEFAULT, helper_text: nil, validation: DEFAULT,
                     validation_message: nil, **options)
        if attribute && form.nil?
          raise ArgumentError, "Gustwave::Form::Field needs `form:` for the attribute #{attribute.inspect}. " \
                               "Without a form builder, set the label and the control yourself."
        end

        @attribute = attribute
        @form = form
        @label = label
        @helper_text = helper_text
        @validation_message = validation_message
        @options = options
        @control_id = generate_random_id(prefix: "field")
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
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

      def call
        tag.div(**@options) do
          safe_join([ label_element, control_element, helper_text_element, validation_message_element ].compact)
        end
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
        if @label.equal?(DEFAULT)
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
