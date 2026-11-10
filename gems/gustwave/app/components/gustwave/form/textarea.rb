# frozen_string_literal: true

module Gustwave
  module Form
    # Use Textarea to render Flowbite's textarea: a multi-line text field.
    # Flowbite shows it in one size, so there is no +size+ option. Rails'
    # +size: "20x40"+ sets +cols+ and +rows+ as in any Rails form.
    #
    # +options+ are the +<textarea>+'s HTML attributes, e.g. +rows+,
    # +placeholder+ and +maxlength+. The label, helper text and validation
    # message belong to Gustwave::Form::Field.
    #
    # === Without a form builder
    #
    # Renders a plain +<textarea>+. +name+ and +id+ are ordinary HTML
    # attributes. The text is the +value+ option, or the block:
    #
    #   <%= render Gustwave::Form::Textarea.new(name: "message", rows: 4, value: "Hello") %>
    #
    #   <%= render Gustwave::Form::Textarea.new(name: "message", rows: 4) { "Hello" } %>
    #
    # === With a form builder
    #
    # Pass the attribute and +form:+, a Rails form builder or any subclass.
    # Rails renders the element, so name, ID, text, nested attributes,
    # +index+ and +namespace+ behave as in any Rails form:
    #
    #   <%= render Gustwave::Form::Textarea.new(:notes, form: f, rows: 4) %>
    #
    # Rails' +field_error_proc+ never wraps the textarea. In the +error+
    # validation state the textarea sets +aria-invalid="true"+, unless the
    # caller's +aria+ options say otherwise.
    #
    # === In a field
    #
    # Gustwave::Form::Field builds the textarea and wires it through
    # +apply_slot_context+ (see there).
    #
    # @status alpha
    class Textarea < Gustwave::Component
      include Gustwave::Form::BoundControl

      # The textarea itself, which is the root element
      part :textarea

      # Flowbite's textarea has the classes of its input field at the default
      # size. It doesn't show a validation or disabled state, so those follow
      # the input field's.
      base textarea: "block w-full border rounded-lg p-2.5 text-sm dark:bg-gray-700"

      variant :validation, part: :textarea, default: :none, values: VALIDATION_LOOK

      # Set when the textarea is disabled
      toggle :disabled_look, part: :textarea, per: :validation, internal: true, values: DISABLED_LOOK

      # @param attribute [Symbol, String, nil] the attribute of the form's object the textarea is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the textarea is a plain +<textarea>+.
      # @param validation [Symbol] the look of the textarea. Defaults to +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+.
      # @param options [Hash] the HTML attributes of the +<textarea>+, e.g. +name+, +id+, +value+, +rows+, +placeholder+, +required+, +disabled+.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, validation: DEFAULT, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(validation:)
      end

      def before_render
        select_options(disabled_look: disabled?)
        @textarea_options = textarea_options
      end

      def call
        if bound?
          render_bound_element(:textarea, bound_form, bound_attribute, @textarea_options)
        else
          options = @textarea_options.dup
          text = options.key?(:value) ? options.delete(:value) : content
          tag.textarea(text, **options)
        end
      end

      private

      def textarea_options
        options = attributes_for(:textarea, @options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end
    end
  end
end
