# frozen_string_literal: true

module Gustwave
  module Form
    # Use FileInput to render a file input: a field that picks files to upload.
    # Like every control, it renders on its own or bound to a form builder, and
    # Gustwave::Form::Field renders it with its label: see
    # {file:README.md#Building_forms Building forms}.
    #
    #   <%= render Gustwave::Form::FileInput.new(name: "avatar", accept: "image/*") %>
    #   <%= render Gustwave::Form::FileInput.new(:attachments, form: f, multiple: true) %>
    #
    # Bound, +multiple: true+ names the input as a list, e.g.
    # +task[attachments][]+. A bound file input marks its form as multipart, so
    # the upload works without +multipart: true+ on the form. Rails'
    # +file_field+ would mark only the copy of the builder that renders the
    # element.
    #
    # @status alpha
    class FileInput < Gustwave::Component
      include Gustwave::Form::BoundControl

      # The file input itself, which is the root element
      part :input

      # The classes shared by every size and validation state
      base input: "block w-full border rounded-lg cursor-pointer focus:outline-none dark:bg-gray-700"

      variant :size, part: :input, default: :md, values: {
        sm: "text-xs",
        md: "text-sm",
        lg: "text-lg"
      }

      # Flowbite shows no validation look for the file input, so the states
      # use the input field's colors and the default look is Flowbite's file
      # input.
      variant :validation, part: :input, default: :none, values: {
        none: "bg-gray-50 border-gray-300 text-gray-900 dark:text-gray-400 dark:border-gray-600 dark:placeholder-gray-400",
        success: VALIDATION_LOOK[:success],
        error: VALIDATION_LOOK[:error]
      }

      # Set when the file input is disabled
      toggle :disabled_look, part: :input, per: :validation, internal: true, values: DISABLED_LOOK

      # @param attribute [Symbol, String, nil] the attribute of the form's object the file input is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the file input is a plain +<input type="file">+.
      # @param size [Symbol] the size of the file input. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+. The HTML attribute +size+ goes in +html:+.
      # @param validation [Symbol] the look of the file input. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+, unless the caller's +aria+ options say otherwise.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +name+, +id+, +multiple+, +accept+, +required+, +disabled+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, size: DEFAULT, validation: DEFAULT, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(size:, validation:)
      end

      def before_render
        select_options(disabled_look: disabled?)
        @input_options = input_options
      end

      def call
        if bound?
          bound_form.multipart = true
          render_bound_element(:file_field, bound_form, bound_attribute, @input_options)
        else
          tag.input(**@input_options, type: :file)
        end
      end

      private

      def input_options
        options = attributes_for(:input, @options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end
    end
  end
end
