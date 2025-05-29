# frozen_string_literal: true

module Gustwave
  class Badge < Gustwave::Buttons::Base
    attr_reader :id

    DEFAULT_TAG = :span
    TAG_OPTIONS = [ :div, :span, :button, :a ].freeze

    # \Tags rendering +hover+ style
    HOVER_TAGS = [ :button, :a ].freeze

    DEFAULT_TYPE = nil
    TYPE_OPTIONS = [ nil, :button, :submit, :reset ].freeze

    style :base,
          "rounded whitespace-nowrap inline-flex"

    style :scheme,
          default: :default,
          states: {
            none: "",
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
    # TODO remove this
    SCHEME_OPTIONS = layer_states(:scheme).keys.excluding(:none, :base).freeze

    mapping :scheme_to_dismiss_button_scheme, {
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

    style :hover,
          default: :default,
          states: {
            none: "",
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

    style :size,
          default: :xs,
          states: {
            xs: "px-2.5 py-0.5 text-xs font-medium",
            sm: "px-2.5 py-0.5 text-sm font-medium",
            md: "px-2.5 py-0.5 text-base font-semibold",
            lg: "px-2.5 py-0.5 text-lg font-semibold",
            xl: "px-2.5 py-0.5 text-xl font-bold",
            "2xl": "px-2.5 py-0.5 text-2xl font-extrabold"
          }

    mapping :size_to_dismiss_button_size, {
      xs: :"3xs",
      sm: :"3xs",
      md: :"3xs",
      lg: :"2xs",
      xl: :"2xs",
      "2xl": :"xs"
    }

    style :visual_size,
          strategy: :merge,
          states: {
            "2xl": "h-8 w-auto"
          }

    style :size_dismiss_button_size,
          default: :xs,
          states: {
            xs: "p-1",
            sm: "p-1",
            md: "p-1",
            lg: "p-1.5",
            xl: "p-1.5",
            "2xl": "p-2"
          }

    # Render a square button when no text or content block was given
    style :size_overwrite_if_visual_only,
          default: default_layer_state(:size),
          states: {
            none: "",
            xs: "rounded-full px-0.5",
            sm: "rounded-full px-0.5",
            md: "rounded-full px-0.5",
            lg: "rounded-full px-0.5",
            xl: "rounded-full px-0.5",
            "2xl": "rounded-full px-0.5"
          }

    # Note +border+ increases buttons dimensions by 1px on all edges. Prefer
    # +outline+ to render bordered and non-bordered badges side-by-side.
    style :border,
          default: :default,
          states: {
            none: "",
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


    style :outline,
          default: :default,
          states: {
            none: "",
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

    # Renders a dismiss button to dismiss the badge visually.
    #
    # Note: Using a dismiss button inside an anchor tag does not work.
    #
    # @param text [String, nil] text to display to screen readers. If missing block content is rendered without +sr-only+ markup. If both are missing a localized version of "Dismiss" is used.
    # @param icon [Symbol] The icon to use for the dismiss button. Defaults to `:dismiss`.
    # @param options [Hash] Additional HTML options passed to the button component.
    renders_one :dismiss_button_slot, ->(text = nil, icon: :dismiss, **options, &block) {
      # Make sure the badge has an id that can be used to dismiss it.
      @id ||= generate_random_id(prefix: "badge")

      a11y_text = sr_only(text) || (capture(&block) if block.present?) || sr_only("Dismiss")
      config = configure_component(
        options,
        theme: :inline,
        scheme: scheme_to_dismiss_button_scheme_mapping(@scheme),
        size: size_to_dismiss_button_size_mapping(@size),
        class: styles(size_dismiss_button_size: @size, custom: "bg-transparent"),
        aria: { label: :remove },
        data: { dismiss_target: "##{@id}" }
      )

      component = Gustwave::Button.new(a11y_text, **config)
      component.leading_icon icon, stroke_width: 2 if icon
      component
    }
    alias dismiss_button with_dismiss_button_slot

    # @param text [String, NilClass] Text to display within the badge. Takes precedence over block content.
    # @param tag [Symbol] The HTML tag to use for the badge. Defaults to :span. Valid values are :div, :span, :button, and :a. Be aware, that :a and :button tags are not supported when using a dismiss button.
    # @param type [Symbol] The HTML type attribute to use for the badge. Defaults to +nil+. Valid values are +nil+, :button, :submit, and :reset.
    # @param scheme [Symbol] The color scheme for the badge. Defaults to :default.
    # @param size [Symbol] The size of the badge. Defaults to :xs.
    # @param pill [Boolean] Rounds the Badge corners to make it look like a pill. Defaults to +false+.
    # @param border [Boolean] Whether the badge includes a border. Border adds 1px to all edges. Defaults to +false+.
    # @param outline [Boolean] Whether the badge includes an outline. Outline keeps the badges dimensions consistent between outlined and non-outlined badges. Defaults to +false+.
    # @param options [Hash] Additional HTML options passed to the component.
    def initialize(
      text = nil,
      tag: DEFAULT_TAG,
      type: DEFAULT_TYPE,
      scheme: default_layer_state(:scheme),
      size: default_layer_state(:size),
      pill: false,
      border: false,
      outline: false,
      **options
    )
      super(text, scheme:, size:, pill:, **options)

      @id = options.delete(:id)
      @html_tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)
      @kwargs.merge!(
        type: fetch_or_fallback(TYPE_OPTIONS, type, DEFAULT_TYPE),
        border: (@scheme if fetch_or_fallback_boolean(border, false)),
        outline: (@scheme if fetch_or_fallback_boolean(outline, false)),
        hover: (@scheme if tag.in?(HOVER_TAGS))
      )
    end

    def before_render
      super
      @config[:id] = id
    end

    def call
      content_tag html_tag, config do
        slots_and_content(
          leading_visuals,
          text_or_content,
          trailing_visuals,
          dismiss_button_slot,
          append_content: false
        )
      end
    end

    private
  end
end
