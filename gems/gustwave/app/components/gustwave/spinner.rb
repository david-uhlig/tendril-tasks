# frozen_string_literal: true

module Gustwave
  # Use Spinner as a loading indicator
  class Spinner < Gustwave::Component
    include Gustwave::Positionable

    style :base, "inline animate-spin"

    style :scheme,
          default: :blue,
          states: {
            none: "",
            base: "",
            blue: "text-gray-200 dark:text-gray-600 fill-blue-600",
            dark: "text-gray-200 dark:text-gray-600 fill-gray-600 dark:fill-gray-300",
            green: "text-gray-200 dark:text-gray-600 fill-green-500",
            red: "text-gray-200 dark:text-gray-600 fill-red-600",
            yellow: "text-gray-200 dark:text-gray-600 fill-yellow-400",
            pink: "text-gray-200 dark:text-gray-600 fill-pink-600",
            purple: "text-gray-200 dark:text-gray-600 fill-purple-600"
          }

    style :align,
          default: :none,
          states: {
            none: "",
            left: "text-left rtl:text-right",
            center: "text-center",
            right: "text-right rtl:text-left"
          }

    # @param text [String, nil] the text to display to screen readers. Takes precedence over block content. If neither is provided, a i18n version of "Loading..." is used. Block content must render sr-only markup itself, e.g. "<span class='sr-only'>Loading...</span>".
    # @param scheme [Symbol] the color scheme for the spinner. To further customize use `fill-{*}` to change the main colors, use `text-{*}` to change the background by passing these CSS classes through the options hash.
    # @param size [Symbol] the size of the spinner. Pass in t-shirt sizes from :xs to :"9xl" to change the size. Passthrough to Gustwave::Icon.
    # @param align [Symbol] the text alignment of the spinner. Pass in :none, :left, :center, or :right to change the alignment.
    # @param position [Symbol] the position of the spinner relative to its enclosing element. Make sure the enclosing element has the Tailwind class +relative+. See Gustwave::Positionable for options.
    # @param options [Hash] additional HTML attributes for the wrapping div tag. Use #configure_icon to customize the SVG icon tag.
    #
    # @see Gustwave::Icon
    # @see Gustwave::Positionable for positioning options
    def initialize(text = nil, scheme: :blue, size: :md, align: :none, position: :none, **options)
      @text = sr_only_text(text)
      @config = configure_html_attributes(
        options,
        role: "status",
        class: styles(align:, position:)
      )
      @size = size
      @kwargs = {
        base: (true unless scheme == :none),
        scheme:
      }
      configure_icon
    end

    # @param options [Hash] additional HTML attributes and component options for the Gustwave::Icon component.
    def configure_icon(**options)
      @icon_config = configure_component(
        options,
        size: @size,
        position: :standalone,
        aria_hidden: true,
        class: styles(**kwargs)
      )
    end

    def before_render
      @text ||= content || sr_only_text(t(".loading"))
    end

    def call
      content_tag :div, config do
        safe_join([ spinner_icon, text ])
      end
    end

    private
    attr_reader :config, :icon_config, :text, :kwargs

    def sr_only_text(text = nil)
      return nil unless text.present?

      tag.span class: "sr-only" do
        text
      end
    end

    def spinner_icon
      render Gustwave::Icon.new(:spinner, **icon_config)
    end
  end
end
