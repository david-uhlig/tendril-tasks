# frozen_string_literal: true

module Gustwave
  module Buttons
    # Use Base as a building block for button themes
    class Base < Gustwave::Component
      DEFAULT_TAG = :button
      TAG_OPTIONS = [ :button, :a ].freeze

      DEFAULT_TYPE = :button
      TYPE_OPTIONS = [ :button, :reset, :submit ].freeze

      SIZE_INDICATOR_MAPPINGS = {
        none: :none,
        xs: :sm,
        sm: :sm,
        md: :md,
        lg: :md,
        xl: :lg
      }.freeze

      style :base,
            "rounded-lg focus:outline-hidden focus:ring-4 text-center overflow-hidden whitespace-nowrap align-bottom disabled:cursor-not-allowed"

      # General appearance of the buttons
      #
      # Merge with your own states when inheriting from this class
      #
      #   style :scheme,
      #         strategy: :merge,
      #         default: :red,
      #         states: {
      #           red: "bg-red-500 hover:bg-red-600 focus:ring-red-300",
      #           green: "bg-green-500 hover:bg-green-600 focus:ring-green-300"
      #         }
      style :scheme,
            default: :base,
            states: {
              none: "", # Also excludes the `base` style
              base: "" # Includes the `base` style
            }

      style :size,
            default: :md,
            states: {
              none: "",
              xs: "h-8 px-3 py-2 text-xs font-medium",
              sm: "h-9 px-3 py-2 text-sm font-medium",
              md: "h-10 px-5 py-2.5 text-sm font-medium",
              lg: "h-12 px-5 py-3 text-base font-medium",
              xl: "h-13 px-6 py-3.5 text-base font-medium"
            }

      # Render a square button when no text or content block was given
      style :size_overwrite_if_visual_only,
            default: default_layer_state(:size),
            states: {
              none: "",
              xs: "p-2",
              sm: "p-2",
              md: "p-2.5",
              lg: "p-3",
              xl: "p-3.5"
            }

      style :pill,
            "rounded-full"

      # This is added to the button's HTML element when a leading or trailing
      # visual is present
      style :has_visual,
            "inline-flex items-center align-bottom gap-1.5"

      # Adjusts the visual's size based on the +text-*+ class of the
      # +style :size+ states.
      style :visual_size,
            default: default_layer_state(:size),
            states: {
              none: "",
              xs: "h-4 w-auto",
              sm: "h-5 w-auto",
              md: "h-5 w-auto",
              lg: "h-6 w-auto",
              xl: "h-7 w-auto"
            }

      # Renders visual elements to appear to the left of the button text.
      #
      # Typically used for icons or decorative visuals going with the button
      # label.
      #
      # +aria-hidden="true"+ is automatically applied to hide the image from
      # screen readers, as it is usually decorative and doesn't convey critical
      # information.
      #
      # === Basic usage
      #   render Gustwave::Buttons::Base.new do |button|
      #     button.leading_image src: "icon.svg", alt: "Icon description"
      #     "Submit"
      #   end
      #
      # === With custom options
      #   render Gustwave::Buttons::Base.new do |button|
      #     button.leading_image src: "icon.svg", alt: "Icon description", class: "w-10 h-10 me-4"
      #     "Submit"
      #   end
      #
      # === Custom visual components
      # Pass any component with +leading_renderable+ or +trailing_renderable+.
      # If it implements +apply_slot_context+, the button calls it when the slot
      # is set, with:
      # - +slot:+ [Symbol] +:leading_visuals+ or +:trailing_visuals+.
      # - +size:+ [Symbol] the button's size: +:none+, +:xs+, +:sm+, +:md+, +:lg+ or +:xl+.
      # - +html_attributes:+ [Hash] the attributes the built-in visuals get:
      #   +aria: { hidden: true }+ and the size classes for +size+, e.g.
      #   +h-6 w-auto+ for +:lg+.
      # The button may add keys later, so accept unknown ones with +**+.
      # Components without +apply_slot_context+ render unchanged.
      #
      #   class MyAvatar < Gustwave::Component
      #     def initialize(src, **options)
      #       @src = src
      #       @options = options
      #     end
      #
      #     def apply_slot_context(html_attributes:, **)
      #       # The caller's own options take precedence over the button's.
      #       @options = configure_html_attributes(@options, **html_attributes)
      #     end
      #
      #     def call
      #       image_tag @src, **@options
      #     end
      #   end
      #
      #   button.leading_renderable(MyAvatar.new("me.png", class: "rounded-full"))
      #
      # === Adding a visual type to every theme
      # Extend this class whenever it loads, so the type survives code
      # reloading. Every theme inherits it:
      #
      #   # config/initializers/gustwave.rb
      #   Rails.autoloaders.main.on_load("Gustwave::Buttons::Base") do |base, _abspath|
      #     base.extend_slot :leading_visuals, types: {
      #       badge: ->(text) { tag.mark(text, **configure_visual_html_attributes({ class: "badge" })) }
      #     }
      #   end
      #
      #   button.with_leading_visual_badge("new")
      #
      # Pass your own attributes to +configure_visual_html_attributes+ as a hash,
      # not as keywords: keywords count as defaults and replace the size classes.
      renders_many_extensible :leading_visuals, types: {
        icon: ->(name, theme: :outline, **options) {
          config = configure_visual_html_attributes(
            options,
            theme:,
            position: :standalone,
          )
          Gustwave::Icon.new(name, **config)
        },
        image: ->(src, **options) {
          config = configure_visual_html_attributes(options)
          image_tag src, **config
        },
        svg: ->(src = nil, **options, &block) {
          config = configure_visual_html_attributes(options)
          Gustwave::Svg.new(src, **config, &block)
        },
        indicator: ->(text = nil, **options, &block) {
          config = configure_html_attributes(
            options,
            aria: { hidden: true },
            size: SIZE_INDICATOR_MAPPINGS[@size],
            )
          Gustwave::Indicator.new(text, **config, &block)
        }
      }, renderable: :visual_context
      alias leading_icon with_leading_visual_icon
      alias leading_image with_leading_visual_image
      alias leading_svg with_leading_visual_svg
      alias leading_indicator with_leading_visual_indicator
      alias leading_renderable with_leading_visual_renderable

      renders_many_extensible :trailing_visuals, types: {
        icon: ->(name, theme: :outline, **options) {
          config = configure_visual_html_attributes(
            options,
            theme:,
            position: :standalone
          )
          Gustwave::Icon.new(name, **config)
        },
        image: ->(src, **options) {
          config = configure_visual_html_attributes(options)
          image_tag src, **config
        },
        svg: ->(src = nil, **options, &block) {
          config = configure_visual_html_attributes(options)
          Gustwave::Svg.new(src, **config, &block)
        },
        indicator: ->(text = nil, **options, &block) {
          config = configure_html_attributes(
            options,
            aria: { hidden: true },
            size: SIZE_INDICATOR_MAPPINGS[@size],
          )
          Gustwave::Indicator.new(text, **config, &block)
        }
      }, renderable: :visual_context
      alias trailing_icon with_trailing_visual_icon
      alias trailing_image with_trailing_visual_image
      alias trailing_svg with_trailing_visual_svg
      alias trailing_indicator with_trailing_visual_indicator
      alias trailing_renderable with_trailing_visual_renderable

      # @param text [String, nil] text to display on the button. Takes precedence over block content.
      # @param tag [Symbol] The HTML tag to use for the button. Options: :a and :button. Defaults to :button.
      # @param type [Symbol] The type of button. Options: :button, :reset, :submit. Defaults to :button.
      # @param scheme [Symbol] The color scheme of the button. Options: :none and :base.
      # @param size [Symbol] The size of the button. Options: :none, :xs, :sm, :md, :lg, :xl.
      # @param pill [Boolean] Whether to render the button in pill shape.
      # @param options [Hash] HTML attributes to be applied to the button.
      def initialize(text = nil,
                     tag: DEFAULT_TAG,
                     type: DEFAULT_TYPE,
                     scheme: default_layer_state(:scheme),
                     size: default_layer_state(:size),
                     pill: false,
                     **options)
        @text = text
        @size = size # Required for leading/trailing slots
        @scheme = scheme
        @html_tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)
        @options = options

        @kwargs = {
          type: (fetch_or_fallback(TYPE_OPTIONS, type, DEFAULT_TYPE) if @html_tag == :button),
          scheme:,
          size:,
          pill: lightswitch_cast(pill)
        }
      end

      def before_render
        # Must build config here to know whether block content was passed
        @config = configure_html_attributes(
          @options,
          type: @kwargs.delete(:type),
          class: styles(
            base: render_base_styles?,
            **@kwargs,
            has_visual: has_visual?,
            size_overwrite_if_visual_only: (@size unless has_content?)
          ).presence
        )
      end

      def call
        content_tag html_tag, config do
          slots_and_content(leading_visuals, text_or_content, trailing_visuals, append_content: false)
        end
      end

      private
      attr_reader :html_tag, :config, :scheme

      def has_visual?
        @has_visual ||= leading_visuals? || trailing_visuals?
      end

      def has_content?
        @has_content ||= text_or_content.present?
      end

      def render_base_styles?
        @render_base_styles ||= !scheme.eql?(:none)
      end

      # Context for components passed to the +renderable+ visual type that
      # implement +apply_slot_context+. Documented at +leading_visuals+ under
      # "Custom visual components"; keep both in sync.
      def visual_context
        { size: @size, html_attributes: configure_visual_html_attributes }
      end

      def configure_visual_html_attributes(overwrite_attrs = {}, **default_attrs)
        configure_html_attributes(
          overwrite_attrs,
          aria: { hidden: true },
          class: styles(visual_size: @size),
          **default_attrs
        )
      end
    end
  end
end
