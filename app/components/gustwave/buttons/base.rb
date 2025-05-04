# frozen_string_literal: true

module Gustwave
  module Buttons
    class Base < Gustwave::Component
      DEFAULT_TAG = :button
      TAG_OPTIONS = [ :button, :a ].freeze

      DEFAULT_TYPE = :button
      TYPE_OPTIONS = [ :button, :reset, :submit ].freeze

      style :base,
            "rounded-lg focus:outline-none focus:ring-4 text-center overflow-hidden whitespace-nowrap align-bottom disabled:cursor-not-allowed gap-1.5"

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
              xs: "px-3 py-2 text-xs font-medium",
              sm: "px-3 py-2 text-sm font-medium",
              md: "px-5 py-2.5 text-sm font-medium",
              lg: "px-5 py-3 text-base font-medium",
              xl: "px-6 py-3.5 text-base font-medium"
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
            "inline-flex items-center align-bottom"

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
              xl: "h-6 w-auto"
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
      renders_many :leading_visuals, types: {
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
            size: :auto,
            )
          Gustwave::Indicator.new(text, **config, &block)
        }
      }
      alias leading_icon with_leading_visual_icon
      alias leading_image with_leading_visual_image
      alias leading_svg with_leading_visual_svg
      alias leading_indicator with_leading_visual_indicator

      renders_many :trailing_visuals, types: {
        icon: ->(name, theme: :outline, **options) {
          config = configure_visual_html_attributes(
            options,
            theme:,
            position: :standalone
          )
          Gustwave::Icon.new(name, **config)
        },
        image: ->(src, **options) {
          config = configure_visual_html_attributes(**options)
          image_tag src, config
        },
        svg: ->(src = nil, **options, &block) {
          config = configure_visual_html_attributes(**options)
          Gustwave::Svg.new(src, **config, &block)
        },
        indicator: ->(text = nil, **options, &block) {
          config = configure_html_attributes(
            options,
            aria: { hidden: true },
            size: :auto,
          )
          Gustwave::Indicator.new(text, **config, &block)
        }
      }
      alias trailing_icon with_trailing_visual_icon
      alias trailing_image with_trailing_visual_image
      alias trailing_svg with_trailing_visual_svg
      alias trailing_indicator with_trailing_visual_indicator

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
          )
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
