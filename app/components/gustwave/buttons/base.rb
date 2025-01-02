# frozen_string_literal: true

module Gustwave
  module Buttons
    class Base < Gustwave::Component
      DEFAULT_TAG = :button
      TAG_OPTIONS = [ :button, :a ].freeze

      DEFAULT_TYPE = :button
      TYPE_OPTIONS = [ :button, :reset, :submit ].freeze

      style :base,
            "rounded-lg focus:outline-none focus:ring-4 text-center overflow-hidden whitespace-nowrap align-bottom disabled:cursor-not-allowed disabled:opacity-80"

      # General appearance of the buttons
      #
      # Merge with your own states when inheriting from this class
      #
      #   style :scheme,
      #         strategy: :merge,
      #         default: :red,
      #         states: {
      #           red: "bg-red-500 hover:bg-red-600 focus:ring-red-300",
      #         green: "bg-green-500 hover:bg-green-600 focus:ring-green-300"
      #         }
      #   DEFAULT_SCHEME = default_layer_state(:scheme)
      #
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

      style :pill,
            "rounded-full"

      # This is added to the button's HTML element when a leading or trailing
      # visual is present
      style :has_visual,
            "inline-flex items-center align-bottom"

      style :leading_visual_size,
            default: default_layer_state(:size),
            states: {
              xs: "h-4 me-1",
              sm: "h-5 me-1.5",
              md: "h-5 me-1.5",
              lg: "h-6 me-2",
              xl: "h-6 me-2"
            }

      style :trailing_visual_size,
            default: default_layer_state(:size),
            states: {
              xs: "h-4 ms-1",
              sm: "h-5 ms-1.5",
              md: "h-5 ms-1.5",
              lg: "h-6 ms-2",
              xl: "h-6 ms-2"
            }

      # Renders an image or visual element to appear to the left of the button text.
      # This is typically used for icons or decorative visuals accompanying the button label.
      #
      # @param src [String] The source URL or path to the image file to display.
      # @param alt [String, nil] The alternative text for the image, useful for accessibility.
      #   If not provided, the image will have no `alt` text.
      # @param classes [String] A string of CSS classes for controlling the image size and appearance.
      #   Defaults to "w-5 h-5 me-2", which applies width and height of 5 units and a margin-end of 2 units
      #   (based on Tailwind CSS utility classes).
      #
      # @example Basic usage
      #   render(ButtonComponent.new) do |button|
      #     button.leading_visual src: "icon.svg", alt: "Icon description"
      #     "Submit"
      #   end
      #
      # @example Custom classes
      #   render(ButtonComponent.new) do |button|
      #     button.leading_visual src: "icon.svg", alt: "Icon description", classes: "w-10 h-10 me-4"
      #     "Submit"
      #   end
      #
      # @note The `aria-hidden="true"` attribute is automatically applied to hide the image from screen readers,
      #   as it is usually decorative and doesn't convey critical information.
      #
      renders_one :leading_visual, types: {
        image: ->(src, **options) {
          options.deep_symbolize_keys!
          options[:class] = styles(leading_visual_size: @size,
                                   custom: options.delete(:class))
          options[:"aria-hidden"] = options.delete(:"aria-hidden") || "true"
          image_tag src, options
        },
        svg: ->(**options, &block) {
          options.deep_symbolize_keys!
          options[:class] = styles(leading_visual_size: @size,
                                   custom: options.delete(:class))
          options[:"aria-hidden"] = options.delete(:"aria-hidden") || "true"
          content_tag :svg, **options, &block
        }
      }
      alias with_leading_visual with_leading_visual_image
      alias leading_image with_leading_visual_image
      alias leading_svg with_leading_visual_svg

      renders_one :trailing_visual, types: {
        image: ->(src, **options) {
          options.deep_symbolize_keys!
          options[:class] = styles(trailing_visual_size: @size,
                                   custom: options.delete(:class))
          options[:"aria-hidden"] = options.delete(:"aria-hidden") || "true"
          image_tag src, options
        },
        svg: ->(**options, &block) {
          options.deep_symbolize_keys!
          options[:class] = styles(trailing_visual_size: @size,
                                   custom: options.delete(:class))
          options[:"aria-hidden"] = options.delete(:"aria-hidden") || "true"
          content_tag :svg, **options, &block
        }
      }
      alias trailing_image with_trailing_visual_image
      alias trailing_svg with_trailing_visual_svg

      def initialize(text = nil,
                     tag: DEFAULT_TAG,
                     type: DEFAULT_TYPE,
                     scheme: default_layer_state(:scheme),
                     size: default_layer_state(:size),
                     pill: false,
                     **options)
        @text = text
        @tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)
        @size = size

        options.symbolize_keys!
        layers = {}
        layers[:base] = true unless scheme == :none
        layers[:scheme] = scheme
        layers[:size] = @size
        layers[:pill] = lightswitch_cast(pill)
        layers[:custom] = options.delete(:class)

        options[:class] = styles(**layers)
        options[:type] = fetch_or_fallback(TYPE_OPTIONS, type, DEFAULT_TYPE) if @tag == :button
        @options = options
      end

      def call
        if leading_visual? || trailing_visual?
          @options[:class] = styles(custom: @options.delete(:class),
                                    has_visual: true)
        end

        content_tag @tag, @options do
          concat(leading_visual) if leading_visual?
          concat(@text || content)
          concat(trailing_visual) if trailing_visual?
        end
      end

      private

      def lightswitch_cast(value)
        return value if [ :on, :off ].include?(value)
        return value.to_sym if %w[on off].include?(value)
        fetch_or_fallback_boolean(value, false)
      end
    end
  end
end
