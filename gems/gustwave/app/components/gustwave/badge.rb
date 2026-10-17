# frozen_string_literal: true

module Gustwave
  # Renders leading and trailing visuals, see Gustwave::Visuals.
  class Badge < Gustwave::Component
    include Gustwave::Visuals

    attr_reader :id

    # \Tags rendering +hover+ style
    HOVER_TAGS = [ :button, :a ].freeze

    option :tag, default: :span, values: %i[div span button a]

    # Renders no +type+ attribute by default
    option :type, default: :none, values: %i[none button submit reset]

    base "rounded-sm whitespace-nowrap inline-flex"
    unstyled color: :none

    # +:base+ renders only the base styles.
    variant :color, default: :default, values: {
      base: "",
      default: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300",
      dark: "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300",
      red: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300",
      green: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300",
      yellow: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300",
      indigo: "bg-indigo-100 text-indigo-800 dark:bg-indigo-900 dark:text-indigo-300",
      purple: "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300",
      pink: "bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-300"
    }

    # The color of the dismiss button per badge color
    derive :dismiss_button_color, from: :color, values: {
      none: :none,
      base: :base,
      default: :blue,
      dark: :dark,
      red: :red,
      green: :green,
      yellow: :yellow,
      indigo: :indigo,
      purple: :purple,
      pink: :pink
    }

    # The +visual+ part sizes leading and trailing visuals to match the
    # +text-*+ class of the badge. The dismiss_button part pads the dismiss
    # button per size.
    variant :size, default: :xs, values: {
      xs: { root: "px-2.5 py-0.5 text-xs font-medium", visual: "h-4 w-auto", dismiss_button: "p-1" },
      sm: { root: "px-2.5 py-0.5 text-sm font-medium", visual: "h-5 w-auto", dismiss_button: "p-1" },
      md: { root: "px-2.5 py-0.5 text-base font-semibold", visual: "h-5 w-auto", dismiss_button: "p-1" },
      lg: { root: "px-2.5 py-0.5 text-lg font-semibold", visual: "h-6 w-auto", dismiss_button: "p-1.5" },
      xl: { root: "px-2.5 py-0.5 text-xl font-bold", visual: "h-7 w-auto", dismiss_button: "p-1.5" },
      "2xl": { root: "px-2.5 py-0.5 text-2xl font-extrabold", visual: "h-8 w-auto", dismiss_button: "p-2" }
    }

    # The size of the dismiss button per badge size
    derive :dismiss_button_size, from: :size, values: {
      xs: :"3xs",
      sm: :"3xs",
      md: :"3xs",
      lg: :"2xs",
      xl: :"2xs",
      "2xl": :"xs"
    }

    # The size of leading and trailing indicators per badge size. Indicators
    # scale with the text at :"2xl".
    derive :indicator_size, from: :size, values: {
      none: :none,
      xs: :sm,
      sm: :sm,
      md: :md,
      lg: :md,
      xl: :lg,
      "2xl": :auto
    }

    toggle :pill, "rounded-full"

    # Render a round badge when no text or content block was given
    toggle :visual_only, "rounded-full px-0.5", internal: true

    part :dismiss_button, "bg-transparent"

    # Note +border+ increases buttons dimensions by 1px on all edges. Prefer
    # +outline+ to render bordered and non-bordered badges side-by-side.
    toggle :border, per: :color, values: {
      base: "border border-gray-400",
      default: "border border-blue-400",
      dark: "border border-gray-500",
      red: "border border-red-400",
      green: "border border-green-400",
      yellow: "border border-yellow-300",
      indigo: "border border-indigo-400",
      purple: "border border-purple-400",
      pink: "border border-pink-400"
    }

    toggle :outline, per: :color, values: {
      base: "outline outline-1 outline-gray-400",
      default: "outline outline-1 outline-blue-400",
      dark: "outline outline-1 outline-gray-500",
      red: "outline outline-1 outline-red-400",
      green: "outline outline-1 outline-green-400",
      yellow: "outline outline-1 outline-yellow-300",
      indigo: "outline outline-1 outline-indigo-400",
      purple: "outline outline-1 outline-purple-400",
      pink: "outline outline-1 outline-pink-400"
    }

    # Set for the tags in HOVER_TAGS
    toggle :hover, per: :color, internal: true, values: {
      base: "hover:bg-gray-100",
      default: "hover:bg-blue-200",
      dark: "hover:bg-gray-200",
      red: "hover:bg-red-200",
      green: "hover:bg-green-200",
      yellow: "hover:bg-yellow-200",
      indigo: "hover:bg-indigo-200",
      purple: "hover:bg-purple-200",
      pink: "hover:bg-pink-200"
    }

    # Renders a dismiss button to dismiss the badge visually.
    #
    # Note: Using a dismiss button inside an anchor tag does not work.
    #
    # @param text [String, nil] text to display to screen readers. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param icon [Symbol] The icon to use for the dismiss button. Defaults to `:close`.
    # @param options [Hash] Additional HTML options passed to the button component.
    renders_one_extensible :dismiss_button, ->(text = nil, icon: :close, **options, &block) {
      # Make sure the badge has an id that can be used to dismiss it.
      @id ||= generate_random_id(prefix: "badge")

      a11y_text = sr_only(text) || (capture(&block) if block.present?) || sr_only("Dismiss")
      config = {
        theme: :inline,
        color: derived_value(:dismiss_button_color),
        size: derived_value(:dismiss_button_size),
        aria: { label: :remove },
        data: { dismiss_target: "##{@id}" }
      }.merge(attributes_for(:dismiss_button, options))

      component = Gustwave::Button.new(a11y_text, **config)
      component.with_leading_visual_icon icon, stroke_width: 2 if icon
      component
    }

    # @param text [String, NilClass] Text to display within the badge. Takes precedence over block content.
    # @param tag [Symbol] The HTML tag to use for the badge. Defaults to :span. Valid values are :div, :span, :button, and :a. Be aware, that :a and :button tags are not supported when using a dismiss button.
    # @param type [Symbol] The HTML type attribute to use for the badge. Defaults to +nil+. Valid values are +nil+, :button, :submit, and :reset.
    # @param color [Symbol] The color for the badge. Defaults to :default.
    # @param size [Symbol] The size of the badge. Defaults to :xs.
    # @param pill [Boolean] Rounds the Badge corners to make it look like a pill. Defaults to +false+.
    # @param border [Boolean] Whether the badge includes a border. Border adds 1px to all edges. Defaults to +false+.
    # @param outline [Boolean] Whether the badge includes an outline. Outline keeps the badges dimensions consistent between outlined and non-outlined badges. Defaults to +false+.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(
      text = nil,
      tag: DEFAULT,
      type: DEFAULT,
      color: DEFAULT,
      size: DEFAULT,
      pill: false,
      border: false,
      outline: false,
      **options
    )
      @text = text
      @id = options.delete(:id)
      @options = options

      select_options(tag:, type:, color:, size:, pill:, border:, outline:)
      @html_tag = option_value(:tag)
      select_options(hover: html_tag.in?(HOVER_TAGS))
    end

    def before_render
      # Must build config here to know whether block content was passed
      select_options(has_visual: has_visual?, visual_only: !has_content?)
      @config = { type: type_attribute }.merge(attributes_for(@options))
      @config[:id] = id
    end

    def call
      content_tag html_tag, config do
        slots_and_content(
          leading_visuals,
          text_or_content(text),
          trailing_visuals,
          dismiss_button,
          append_content: false
        )
      end
    end

    private
    attr_reader :html_tag, :config, :text

    def has_content?
      text_or_content(text).present?
    end

    # A badge renders the type of any tag
    def type_attribute
      type = option_value(:type)
      type unless type == :none
    end
  end
end
