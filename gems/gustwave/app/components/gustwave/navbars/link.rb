# frozen_string_literal: true

module Gustwave
  module Navbars
    # A link in a navbar, as in Flowbite's navbars. Renders an +a+ only: the
    # navbar wraps it in a list item.
    #
    # Whether the link is active is up to the caller. Pass +active: true+ to
    # mark the link as the current page with +aria-current="page"+.
    #
    #   render Gustwave::Navbars::Link.new("Home", href: "/", active: true)
    class Link < Gustwave::Component
      base "block py-2 px-3 md:p-0 rounded-sm"

      toggle :active,
             on: "text-white bg-blue-700 md:bg-transparent md:text-blue-700 dark:text-white dark:bg-blue-600 md:dark:bg-transparent md:dark:text-blue-500",
             off: "text-gray-900 hover:bg-gray-100 md:hover:bg-transparent md:hover:text-blue-700 dark:text-white dark:hover:bg-gray-700 dark:hover:text-white md:dark:hover:bg-transparent md:dark:hover:text-blue-500"

      # @param text [String, nil] Text to display within the link. Takes precedence over block content.
      # @param href [String] The URL the link points to.
      # @param active [Boolean] Whether the link is the current page. Defaults to +false+.
      # @param options [Hash] Additional HTML attributes passed to the +a+ element.
      def initialize(text = nil, href:, active: false, **options)
        @text = text
        select_options(active:)
        @options = options.merge(href:)
      end

      def before_render
        @config = attributes_for(@options)
        @config[:"aria-current"] = "page" if option_value(:active)
      end

      def call
        render Gustwave::Link.new(text_or_content(@text), color: :none, underline: :none, **@config)
      end
    end
  end
end
