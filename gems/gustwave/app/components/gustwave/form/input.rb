# frozen_string_literal: true

module Gustwave
  module Form
    # Use Input to render a single-line input field, e.g. for text, an email
    # address or a date. Like every control, it renders on its own or bound to a
    # form builder, and Gustwave::Form::Field renders it with its label: see
    # {file:README.md#Building_forms Building forms}.
    #
    #   <%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) %>
    #   <%= render Gustwave::Form::Input.new(:title, form: f, size: :lg) %>
    #
    # === Visuals
    #
    # A leading visual, e.g. an icon, sits inside the input at its start. The
    # input then renders in an input group, a +relative+ wrapper with
    # the icon beside the input:
    #
    #   <%= render Gustwave::Form::Input.new(:email, form: f, type: :email, icon: :envelope) %>
    #
    #   <%= render Gustwave::Form::Input.new(:email, form: f, type: :email) do |input| %>
    #     <% input.with_leading_visual_icon(:envelope) %>
    #   <% end %>
    #
    # The icon keeps its size and the input its start padding at every +size+.
    #
    # === Trailing action
    #
    # A trailing action, e.g. a search button or a voice search button, sits
    # inside the input at its end, in the same wrapper as a leading visual:
    #
    #   <%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) do |input| %>
    #     <% input.with_trailing_action_button("Search", type: :submit) %>
    #   <% end %>
    #
    #   <%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) do |input| %>
    #     <% input.with_trailing_action_generic do %>
    #       <button type="button" aria-label="Search by voice" class="absolute inset-y-0 end-0 flex items-center pe-3">
    #         <%= render Gustwave::Icon.new(:microphone) %>
    #       </button>
    #     <% end %>
    #   <% end %>
    #
    #   <%= render Gustwave::Form::Input.new(type: :search, name: "q", aria: { label: "Search" }) do |input| %>
    #     <% input.with_trailing_action_renderable(VoiceSearchButton.new) %>
    #   <% end %>
    #
    # A +button+ gets a size that fits the input's +size+, unless the caller
    # gives one. The input reserves no room at its end for the action, so when
    # its text can run under the action, the caller adds the padding, e.g. with
    # <tt>class: "pe-10"</tt> on the input. A +generic+ action or a
    # +renderable+ is positioned by the caller.
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

      # The button size that fits inside the input at each input size.
      ACTION_BUTTON_SIZES = { sm: :xs, md: :xs, lg: :sm }.freeze

      # Classes that place a themed button inside the input at its end, centered vertically.
      ACTION_BUTTON_CLASSES = "absolute end-2.5 top-1/2 -translate-y-1/2"

      private_constant :ACTION_BUTTON_SIZES, :ACTION_BUTTON_CLASSES

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

      variant :validation, part: :input, default: :none, values: VALIDATION_LOOK

      # Set by Gustwave::Form::InputGroup when the input sits beside addons.
      # With a leading visual the wrapper fills the row for the input.
      variant :joined, default: :none, internal: true, values: JOINED_LOOK.to_h { |name, look|
        [ name, { input: look, wrapper: ("flex-1 min-w-0" unless name == :none) }.compact ]
      }

      # Set when the input has a leading visual, which needs room at the start
      toggle :has_visual, "ps-10", part: :input, internal: true

      # Set when the input is disabled, as Flowbite's disabled example does
      toggle :disabled_look, part: :input, per: :validation, internal: true, values: DISABLED_LOOK

      renders_visuals :leading_visuals

      # An action inside the input at its end, rendered beside the input in
      # its wrapper.
      #
      # * +button+: a Gustwave::Button, in the +:default+ theme unless given a +theme+. It takes the options of the theme, and the size that fits the input's +size+ unless it has its own.
      # * +generic+: the block, as it is.
      # * +renderable+: any component, placed by the caller. One that implements +apply_slot_context+ receives +size+.
      #
      #   <% input.with_trailing_action_button("Search", type: :submit) %>
      #   <% input.with_trailing_action_generic { tag.button("Voice", type: "button") } %>
      #   <% input.with_trailing_action_renderable(VoiceSearchButton.new) %>
      renders_one_extensible :trailing_action, types: {
        button: ->(*args, theme: :default, **options) { action_button(*args, theme:, **options) },
        generic: ->(&block) { block&.call }
      }, renderable: :trailing_action_context

      self.visual_icon_theme = :solid

      # @param attribute [Symbol, String, nil] the attribute of the form's object the input is for. Requires +form+.
      # @param form [ActionView::Helpers::FormBuilder, nil] a Rails form builder, or any subclass. Without it the input is a plain +<input>+.
      # @param type [Symbol] the input type. Defaults to +:text+. Valid values are +:text+, +:email+, +:password+, +:number+, +:url+, +:tel+, +:search+, +:date+, +:time+, +:datetime_local+, +:month+ and +:week+.
      # @param size [Symbol] the size of the input. Defaults to +:md+. Valid values are +:sm+, +:md+ and +:lg+. The HTML attribute +size+ goes in +html:+.
      # @param validation [Symbol] the look of the input. Defaults to +:error+ while a bound attribute has errors, otherwise +:none+. Valid values are +:none+, +:success+ and +:error+. +:error+ also sets +aria-invalid+, unless the caller's +aria+ options say otherwise.
      # @param icon [Symbol, nil] the name of an icon rendered as leading visual. Shorthand for +with_leading_visual_icon+.
      # @param options [Hash] the HTML attributes of the +<input>+, e.g. +name+, +id+, +value+, +placeholder+, +required+, +disabled+. +html:+ takes them as a hash, see Gustwave::Component.new.
      # @raise [ArgumentError] for an +attribute+ without +form+.
      def initialize(attribute = nil, form: nil, type: DEFAULT, size: DEFAULT, validation: DEFAULT, icon: nil, **options)
        require_form_for_attribute(attribute, form)

        @attribute = attribute
        @form = form
        @icon = icon
        @options = options
        @validation_given = !validation.nil? && !validation.equal?(DEFAULT)
        @size_given = !size.equal?(DEFAULT)
        select_options(type:, size:, validation:)
      end

      def before_render
        with_leading_visual_icon(@icon) if @icon
        select_options(has_visual: has_visual?, disabled_look: disabled?)
        @input_options = input_options
      end

      def call
        return element unless leading_visuals? || trailing_action?

        tag.div(class: classes(:wrapper)) do
          safe_join([ (tag.div(safe_join(leading_visuals), class: classes(:icon_container)) if leading_visuals?), element, trailing_action ].compact)
        end
      end

      private

      def element
        if bound?
          render_bound_element(HELPERS.fetch(option_value(:type)), bound_form, bound_attribute, @input_options)
        else
          tag.input(type: html_type, **@input_options)
        end
      end

      # +datetime_local+ is spelled +datetime-local+ in HTML
      def html_type = option_value(:type).to_s.tr("_", "-")

      # The button of +theme+ inside the input. Its size fits the input's size,
      # and the classes that place it come ahead of the caller's, so the
      # caller's own size and classes win.
      def action_button(*args, theme:, **options)
        defaults = { size: ACTION_BUTTON_SIZES.fetch(option_value(:size)) }
        Gustwave::Button.for(theme).new(*args, **defaults.merge(options, class: [ ACTION_BUTTON_CLASSES, options[:class] ]))
      end

      # The context a +renderable+ action receives: the input's size.
      def trailing_action_context = { size: option_value(:size) }

      def input_options
        options = attributes_for(:input, @options)
        options[:id] = explicit_id if explicit_id
        merge_aria(options)
      end
    end
  end
end
