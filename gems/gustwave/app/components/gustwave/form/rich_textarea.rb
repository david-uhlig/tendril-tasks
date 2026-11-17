# frozen_string_literal: true

module Gustwave
  module Form
    # Use RichTextarea to render a rich text editor, Lexxy or Trix, in a
    # frame with its toolbar: a bar above the editor, below it or both.
    #
    # === Without a form builder
    #
    # The editor renders +value+ as its content:
    #
    #   <%= render Gustwave::Form::RichTextarea.new(name: "article[body]", value: "<p>Hello</p>") %>
    #
    # === With a form builder
    #
    # Pass the attribute and +form:+, a Rails form builder or any subclass.
    # Rails renders the editor, so name, ID, content, nested attributes,
    # +index+ and +namespace+ behave as in any Rails form:
    #
    #   <%= render Gustwave::Form::RichTextarea.new(:body, form: f) %>
    #
    # Rails' +field_error_proc+ never wraps the editor.
    #
    # === Toolbar
    #
    # The default toolbar sits in the header. +with_footer_toolbar+ moves it
    # below the editor. +hidden:+ and +disabled:+ go to the toolbar, e.g.
    # <tt>with_header_toolbar(hidden: %i[table])</tt>. There is one toolbar at
    # most. <tt>toolbar: false</tt> renders none, and <tt>toolbar: "id"</tt>
    # connects a toolbar of your own, which renders anywhere on the page:
    #
    #   <%= render Gustwave::Form::RichTextarea.new(:body, form: f) do |editor| %>
    #     <% editor.with_footer_toolbar(hidden: %i[table]) %>
    #   <% end %>
    #
    # === Header and footer
    #
    # Each bar takes a +toolbar+ type, as above, or a +generic+ type: a block
    # of your own, e.g. a title or a submit button. A header with generic
    # content needs the toolbar in the footer, or <tt>toolbar: false</tt>:
    #
    #   <%= render Gustwave::Form::RichTextarea.new(:body, form: f) do |editor| %>
    #     <% editor.with_header_generic { "Post" } %>
    #     <% editor.with_footer_toolbar %>
    #   <% end %>
    #
    # === Sticky toolbar
    #
    # The toolbar sticks to the top of the frame when it's in the header, and
    # to the bottom when it's in the footer, while the editor has focus or the
    # pointer is over the frame. <tt>sticky_toolbar: false</tt> turns that
    # off.
    #
    # === In a field
    #
    # Gustwave::Form::Field builds the editor with its label, helper text and
    # validation message, and wires it through +apply_slot_context+, which sets the attribute, the form, the validation
    # state and +aria-describedby+. The toolbar is built after that, so it
    # binds to the form too:
    #
    #   <%= render Gustwave::Form::Field.new(:body, form: f, label: "Body") do |field| %>
    #     <% field.with_control_rich_textarea(editor: :trix) do |editor| %>
    #       <% editor.with_footer_toolbar %>
    #     <% end %>
    #   <% end %>
    #
    # @status alpha
    class RichTextarea < Gustwave::Component
      include Gustwave::Form::BoundControl
      include Gustwave::Form::Framed

      # The toolbar component of each editor
      TOOLBARS = {
        lexxy: "Gustwave::Form::RichText::Lexxy::Toolbar",
        trix: "Gustwave::Form::RichText::Trix::Toolbar"
      }.freeze

      # The class each editor's own stylesheet styles its content with
      CONTENT_CLASSES = { lexxy: "lexxy-content", trix: "trix-content" }.freeze

      # The editor whose toolbar and content class the component uses. The
      # editor element itself is what Rails' +rich_textarea+ renders.
      option :editor, default: :lexxy, values: %i[lexxy trix]

      # The editor element, borderless inside the frame's body
      part :editor, "block w-full min-h-80 px-0 text-sm text-gray-800 border-0 focus:outline-hidden " \
                    "dark:bg-gray-800 dark:text-white dark:placeholder-gray-400"

      # The validation state colors the frame's border; the editor has no
      # classes of its own for it.
      variant :validation, part: :editor, default: :none, values: { none: "", success: "", error: "" }

      # Keeps the toolbar in view while the editor has focus or the pointer
      toggle :sticky_toolbar, "group", part: :frame, default: true

      # The bar that sticks, set to where the toolbar is
      variant :sticky, default: :none, internal: true, values: {
        header: { header: "group-focus-within:sticky group-hover:sticky top-0 z-10 rounded-t-lg bg-gray-50 dark:bg-gray-700" },
        footer: { footer: "group-focus-within:sticky group-hover:sticky bottom-0 z-10 rounded-b-lg bg-gray-50 dark:bg-gray-700" }
      }

      # The bar above the editor.
      #
      # * +toolbar+: the editor's toolbar, built and connected by the
      #   component. Takes the toolbar's options, e.g. +hidden:+ and +disabled:+.
      # * +generic+: a block.
      #
      #   <% editor.with_header_toolbar(hidden: %i[table attach_files]) %>
      renders_one_extensible :header, types: {
        toolbar: ->(**options) { build_toolbar(:header, **options) },
        generic: ->(&block) { block&.call }
      }

      # The bar below the editor. Takes the types of +header+.
      #
      #   <% editor.with_footer_toolbar %>
      renders_one_extensible :footer, types: {
        toolbar: ->(**options) { build_toolbar(:footer, **options) },
        generic: ->(&block) { block&.call }
      }

      # The ID of the toolbar the component builds, which the editor's
      # +toolbar+ attribute carries.
      attr_reader :toolbar_id

      # @param attribute [Symbol, String, nil] the attribute of the form's object the editor is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the editor is a plain editor element.
      # @param editor [Symbol] the editor. Defaults to +:lexxy+. Valid values are +:lexxy+ and +:trix+. It picks the toolbar and the content class.
      # @param validation [Symbol] the look of the frame's border. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+ on the editor, unless the caller's +aria+ options say otherwise.
      # @param sticky_toolbar [Boolean] whether the toolbar sticks while the editor is in use. Defaults to +true+.
      # @param toolbar_id [String, nil] the ID of the toolbar the component builds, which the editor's +toolbar+ attribute carries. Generated by default.
      # @param frame_options [Hash] the HTML attributes of the frame's +<div>+, e.g. +class+ for its margin.
      # @param header_options [Hash] the HTML attributes of the header bar. Only with a header.
      # @param body_options [Hash] the HTML attributes of the white area around the editor.
      # @param footer_options [Hash] the HTML attributes of the footer bar. Only with a footer.
      # @param options [Hash] the HTML attributes of the editor element, e.g. +name+, +id+, +value+, +placeholder+, +toolbar+ (+false+ or the ID of a toolbar of your own).
      # @raise [ArgumentError] for an +attribute+ without +form+, for a second toolbar, for a generic header without a toolbar, or for a toolbar with +toolbar:+ in +options+.
      def initialize(attribute = nil, form: nil, editor: DEFAULT, validation: DEFAULT, sticky_toolbar: DEFAULT,
                     toolbar_id: nil, frame_options: {}, header_options: {}, body_options: {}, footer_options: {},
                     **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @options = options
        @toolbar_id = toolbar_id.presence || generate_random_id(prefix: "toolbar")
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        frame_part_options(frame: frame_options, header: header_options, body: body_options, footer: footer_options)
        select_options(editor:, validation:, sticky_toolbar:)
      end

      def before_render
        content # runs the block, so the slots are known
        place_default_toolbar
        select_frame(header: header?, footer: footer?, framed: true)
        select_options(sticky: (option_value(:sticky_toolbar) && @toolbar_placement) || :none)
        @editor_options = editor_options
      end

      def call
        render_frame(header: (header.to_s if header?), footer: (footer.to_s if footer?)) { element }
      end

      private

      # The caller's own +toolbar+ attribute, e.g. +false+ or the ID of a
      # toolbar of their own. The component then builds none.
      def own_toolbar? = @options.key?(:toolbar)

      def build_toolbar(placement, **options)
        if own_toolbar?
          raise ArgumentError, "#{self.class.name} got `toolbar:` as an attribute, so it builds no toolbar. " \
                               "Remove `toolbar:` or the #{placement}'s toolbar."
        end
        if @toolbar_placement
          raise ArgumentError, "#{self.class.name} takes one toolbar, and its #{@toolbar_placement} already has it."
        end

        @toolbar_placement = placement
        TOOLBARS.fetch(option_value(:editor)).constantize.new(bound_form, id: toolbar_id, **options)
      end

      def place_default_toolbar
        return if own_toolbar? || @toolbar_placement

        if header?
          raise ArgumentError, "#{self.class.name}: the header holds other content. Place the toolbar with " \
                               "`with_footer_toolbar`, or pass `toolbar: false`."
        end
        with_header_toolbar
      end

      def editor_options
        options = attributes_for(:editor, @options)
        options[:class] = [ options[:class], CONTENT_CLASSES.fetch(option_value(:editor)) ].compact.join(" ")
        options[:id] = explicit_id if explicit_id
        options[:toolbar] = toolbar_id unless own_toolbar?
        merge_aria(options)
      end

      def element
        if bound?
          render_bound_element(:rich_textarea, bound_form, bound_attribute, @editor_options)
        else
          options = @editor_options.dup
          helpers.rich_textarea_tag(options.delete(:name), options.delete(:value), options)
        end
      end
    end
  end
end
