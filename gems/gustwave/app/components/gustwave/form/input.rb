# frozen_string_literal: true

module Gustwave
  module Form
    # Use Input to render Flowbite's input field: a text, email, password,
    # number, URL, phone number, search, date or time input, in three sizes
    # and with a success or error look.
    #
    # +options+ are the +<input>+'s HTML attributes. The label, helper text
    # and validation message belong to Gustwave::Form::Field.
    #
    # === Without a form builder
    #
    # Renders a plain +<input>+. +name+, +id+ and +value+ are ordinary HTML
    # attributes:
    #
    #   <%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) %>
    #
    # === With a form builder
    #
    # Pass the attribute and +form:+, a Rails form builder or any subclass.
    # Rails renders the element, so name, ID, value, type casting, nested
    # attributes, +index+ and +namespace+ behave as in any Rails form:
    #
    #   <%= render Gustwave::Form::Input.new(:title, form: f, size: :lg) %>
    #
    # Rails' +field_error_proc+ never wraps the input. In the +error+
    # validation state the input sets +aria-invalid="true"+, unless the
    # caller's +aria+ options say otherwise.
    #
    # === Visuals
    #
    # A leading visual, e.g. an icon, sits inside the input at its start. The
    # input then renders in Flowbite's input group, a +relative+ wrapper with
    # the icon beside the input. +icon:+ is shorthand for the icon slot:
    #
    #   <%= render Gustwave::Form::Input.new(:email, form: f, type: :email, icon: :envelope) %>
    #
    #   <%= render Gustwave::Form::Input.new(:email, form: f, type: :email) do |input| %>
    #     <% input.with_leading_visual_icon(:envelope) %>
    #   <% end %>
    #
    # The icon keeps its size and the input its start padding at every +size+.
    #
    # === In a field
    #
    # Gustwave::Form::Field builds the input and wires it through
    # +apply_slot_context+ (see there).
    #
    # @status alpha
    class Input < Gustwave::Component
      include Gustwave::Form::BoundControl
      include Gustwave::Visuals

      # Rails' helper of each +type+ option.
      HELPERS = {
        text: :text_field,
        email: :email_field,
        password: :password_field,
        number: :number_field,
        url: :url_field,
        tel: :telephone_field,
        search: :search_field,
        date: :date_field,
        time: :time_field,
        datetime_local: :datetime_local_field,
        month: :month_field,
        week: :week_field
      }.freeze

      # The input type. +datetime_local+ renders +type="datetime-local"+.
      option :type, default: :text, values: HELPERS.keys

      # The input itself, which is the root element unless it has a leading
      # visual.
      part :input

      # The wrapper of the input group, rendered with a leading visual
      part :wrapper, "relative"

      # The container of the leading visuals in the input group
      part :icon_container, "absolute inset-y-0 start-0 flex items-center ps-3.5 pointer-events-none"

      # Flowbite's example icon fills its 16px box, while Gustwave's icons
      # leave a margin inside theirs. So the box is 20px, which draws the icon
      # at Flowbite's size, and starts 2px earlier, which keeps it centered
      # where Flowbite's is. Flowbite shows the icon only at the default size.
      # It keeps its size at every input size.
      part :visual, "h-5 w-5 -ms-0.5 text-gray-500 dark:text-gray-400"

      # The classes shared by every size and validation state
      base input: "block w-full border rounded-lg dark:bg-gray-700"

      variant :size, part: :input, default: :md, values: {
        sm: "p-2 text-xs",
        md: "p-2.5 text-sm",
        lg: "p-4 text-base"
      }

      variant :validation, part: :input, default: :none, values: {
        none: "bg-gray-50 border-gray-300 text-gray-900 focus:ring-blue-500 focus:border-blue-500 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500",
        success: "bg-green-50 border-green-500 text-green-900 dark:text-green-400 placeholder-green-700 dark:placeholder-green-500 focus:ring-green-500 focus:border-green-500 dark:border-green-500",
        error: "bg-red-50 border-red-500 text-red-900 placeholder-red-700 focus:ring-red-500 focus:border-red-500 dark:text-red-500 dark:placeholder-red-500 dark:border-red-500"
      }

      # Set when the input has a leading visual, which needs room at the start
      toggle :has_visual, "ps-10", part: :input, internal: true

      # Set when the input is disabled, as Flowbite's disabled example does
      toggle :disabled_look, part: :input, per: :validation, internal: true, values: {
        none: "bg-gray-100 cursor-not-allowed dark:text-gray-400",
        success: "cursor-not-allowed",
        error: "cursor-not-allowed"
      }

      renders_visuals :leading_visuals

      self.visual_icon_theme = :solid

      # @param attribute [Symbol, String, nil] the attribute of the form's object the input is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the input is a plain +<input>+.
      # @param type [Symbol] the input type. Defaults to +:text+. Valid values are +:text+, +:email+, +:password+, +:number+, +:url+, +:tel+, +:search+, +:date+, +:time+, +:datetime_local+, +:month+ and +:week+.
      # @param size [Symbol] the size of the input. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+.
      # @param validation [Symbol] the look of the input. Defaults to +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+.
      # @param icon [Symbol, nil] the name of an icon rendered as leading visual. Shorthand for +with_leading_visual_icon+.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +name+, +id+, +value+, +placeholder+, +required+, +disabled+.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, type: DEFAULT, size: DEFAULT, validation: DEFAULT, icon: nil, **options)
        if attribute && form.nil?
          raise ArgumentError, "Gustwave::Form::Input needs `form:` for the attribute #{attribute.inspect}. " \
                               "Without a form builder, pass name:, id: and value: as HTML attributes instead."
        end

        @attribute = attribute
        @form = form
        @icon = icon
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        select_options(type:, size:, validation:)
      end

      # Lets a parent bind and wire the input, as Gustwave::Form::Field does.
      # What the caller gave the input itself wins over the context: its own
      # +form+ and attribute, an explicit +validation+ and its own +id+. The
      # parent may add keys later, so unknown ones are accepted.
      #
      # @param attribute [Symbol, String, nil] the attribute to bind to.
      # @param form [ActionView::Helpers::FormBuilder, nil] the form builder to bind to.
      # @param id [String, nil] the ID of an input without a form.
      # @param validation [Symbol, nil] the validation state, unless the caller picked one.
      # @param described_by [String, nil] IDs of the elements describing the input, merged with the caller's +aria-describedby+.
      def apply_slot_context(attribute: nil, form: nil, id: nil, validation: nil, described_by: nil, **)
        @context_attribute = attribute
        @context_form = form
        @context_id = id.presence
        @described_by = described_by.presence
        select_options(validation:) if validation && !@validation_given
      end

      # The ID the input renders: the caller's own, one from the context, or
      # Rails' ID for the bound attribute.
      #
      # @return [String, nil] +nil+ for an unbound input without an ID.
      def html_id
        explicit_id || (bound_form.field_id(bound_attribute) if bound?)
      end

      def before_render
        with_leading_visual_icon(@icon) if @icon
        select_options(has_visual: has_visual?, disabled_look: disabled?)
        @input_options = input_options
      end

      def call
        return element unless leading_visuals?

        tag.div(class: classes(:wrapper)) do
          safe_join([ tag.div(safe_join(leading_visuals), class: classes(:icon_container)), element ])
        end
      end

      private

      def bound_form = @form || @context_form

      def bound_attribute = @attribute || @context_attribute

      def bound? = bound_form.present? && bound_attribute.present?

      # An ID Rails mustn't work out itself. It would add the namespace to a
      # bound ID again.
      def explicit_id = @options[:id].presence || @context_id

      def disabled? = @options[:disabled].present?

      def element
        if bound?
          render_bound_element(HELPERS.fetch(option_value(:type)), bound_form, bound_attribute, @input_options)
        else
          tag.input(**@input_options, type: html_type)
        end
      end

      # +datetime_local+ is spelled +datetime-local+ in HTML
      def html_type = option_value(:type).to_s.tr("_", "-")

      def input_options
        options = attributes_for(:input, @options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end

      # +aria-invalid+ in the error state and +aria-describedby+ from the
      # context, next to the caller's own +aria+ attributes, which win.
      def merge_aria(options)
        aria = (options[:aria] || {}).to_h.symbolize_keys
        flat_invalid = options.key?(:"aria-invalid")
        flat_describedby = options.delete(:"aria-describedby")
        aria[:invalid] = true if option_value(:validation) == :error && !aria.key?(:invalid) && !flat_invalid
        described = [ aria[:describedby] || flat_describedby, @described_by ].compact_blank.join(" ")
        aria[:describedby] = described if described.present?
        aria.empty? ? options : options.merge(aria:)
      end
    end
  end
end
