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
    # === Header and footer
    #
    # A header or footer puts the textarea in Flowbite's frame, borderless.
    # The slots are the content of the bars, e.g. toolbar buttons or a submit
    # button; the bars themselves belong to the frame. The text then comes
    # from +value:+ or the record, not from the block, because the block sets
    # the slots:
    #
    #   <%= render Gustwave::Form::Textarea.new(name: "comment", rows: 4, placeholder: "Write a comment") do |textarea| %>
    #     <% textarea.with_footer do %>
    #       <%= render Gustwave::Buttons::Default.new("Post comment", type: :submit) %>
    #     <% end %>
    #   <% end %>
    #
    # The frame's parts take +frame_options:+, +header_options:+,
    # +body_options:+ and +footer_options:+, e.g. <tt>frame_options: { class:
    # "mb-4" }</tt>. +options+ still go to the +<textarea>+. The validation
    # state colors the frame's border, and the textarea gets +aria-invalid+
    # only. For a real editor such as Lexxy, use
    # Gustwave::Form::RichTextArea.
    #
    # === In a field
    #
    # Gustwave::Form::Field builds the textarea and wires it through
    # +apply_slot_context+ (see there).
    #
    # @status alpha
    class Textarea < Gustwave::Component
      include Gustwave::Form::BoundControl
      include Gustwave::Form::Framed

      # The textarea itself, which is the root element
      part :textarea

      # Flowbite's textarea has the classes of its input field at the default
      # size. It doesn't show a validation or disabled state, so those follow
      # the input field's. In the frame the textarea has none of them.
      base textarea: "block w-full border rounded-lg p-2.5 text-sm dark:bg-gray-700", unless: { layout: :framed }

      # Set to +:framed+ when the textarea has a header or footer: Flowbite's
      # borderless textarea inside the frame.
      variant :layout, part: :textarea, default: :plain, internal: true, values: {
        plain: "",
        framed: "block w-full px-0 text-sm text-gray-900 bg-white border-0 focus:ring-0 dark:bg-gray-800 dark:text-white dark:placeholder-gray-400"
      }

      variant :validation, part: :textarea, default: :none, unless: { layout: :framed }, values: VALIDATION_LOOK

      # Set when the textarea is disabled
      toggle :disabled_look, part: :textarea, per: :validation, internal: true, unless: { layout: :framed },
                             values: DISABLED_LOOK

      # The content of the bar above the textarea, e.g. toolbar buttons. With
      # a header or footer the textarea renders in Flowbite's frame.
      #
      #   <% textarea.with_header do %>
      #     <button type="button">…</button>
      #   <% end %>
      renders_one_extensible :header, ->(&block) { block&.call }

      # The content of the bar below the textarea, e.g. a submit button.
      #
      #   <% textarea.with_footer do %>
      #     <%= render Gustwave::Buttons::Default.new("Post comment", type: :submit) %>
      #   <% end %>
      renders_one_extensible :footer, ->(&block) { block&.call }

      # @param attribute [Symbol, String, nil] the attribute of the form's object the textarea is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the textarea is a plain +<textarea>+.
      # @param validation [Symbol] the look of the textarea. Defaults to +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+.
      # @param frame_options [Hash] the HTML attributes of the frame's +<div>+, e.g. +class+ for its margin. Only with a header or footer.
      # @param header_options [Hash] the HTML attributes of the header bar. Only with a header.
      # @param body_options [Hash] the HTML attributes of the white area around the textarea. Only in the frame.
      # @param footer_options [Hash] the HTML attributes of the footer bar. Only with a footer.
      # @param options [Hash] the HTML attributes of the +<textarea>+, e.g. +name+, +id+, +value+, +rows+, +placeholder+, +required+, +disabled+.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, validation: DEFAULT, frame_options: {}, header_options: {},
                     body_options: {}, footer_options: {}, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        frame_part_options(frame: frame_options, header: header_options, body: body_options, footer: footer_options)
        select_options(validation:)
      end

      def before_render
        content # runs the block, so the slots are known
        select_frame(header: header?, footer: footer?)
        select_options(layout: framed? ? :framed : :plain, disabled_look: disabled?)
        @textarea_options = textarea_options
      end

      def call
        return element unless framed?

        render_frame(header: (header.to_s if header?), footer: (footer.to_s if footer?)) { element }
      end

      private

      def textarea_options
        options = attributes_for(:textarea, @options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end

      # With a header or footer the block sets the slots, so it isn't the text.
      def element
        if bound?
          render_bound_element(:textarea, bound_form, bound_attribute, @textarea_options)
        else
          options = @textarea_options.dup
          text = options.key?(:value) ? options.delete(:value) : (content unless framed?)
          tag.textarea(text, **options)
        end
      end
    end
  end
end
