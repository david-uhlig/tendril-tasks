# frozen_string_literal: true

module Gustwave
  class Pagination < Gustwave::Component
    # One link in a Gustwave::Pagination. The pagination sets its position in
    # the list, its size and its default label. Pass +icon+ to show an icon
    # instead of the text, which then stays for screen readers only.
    class Link < Gustwave::Component
      base "flex items-center justify-center leading-tight border"

      part :icon, "*:stroke-2 rtl:rotate-180"

      # Gustwave's chevrons fill a small part of their 24x24 viewBox. These sizes
      # match the chevron drawn by Flowbite's w-2.5 and w-3 icons, and the negative
      # margins take the empty part of the viewBox out of the link's width.
      variant :size, default: :sm, values: {
        sm: { root: "px-3 h-8", icon: "w-6 h-6 -mx-[7px]" },
        md: { root: "px-4 h-10", icon: "w-7 h-7 -mx-2" }
      }

      toggle :active,
             on: "text-blue-600 border-gray-300 bg-blue-50 hover:bg-blue-100 hover:text-blue-700 dark:border-gray-700 dark:bg-gray-700 dark:text-white",
             off: "text-gray-500 bg-white border-gray-300 hover:bg-gray-100 hover:text-gray-700 dark:bg-gray-800 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700 dark:hover:text-white"

      # Selected by Gustwave::Pagination
      variant :list_position, default: :only, internal: true, values: {
        only: "rounded-lg",
        first: "rounded-s-lg",
        middle: "",
        last: "rounded-e-lg"
      }

      # @param text [String, nil] The link text. Takes precedence over block content.
      # @param href [String] The URL the link points to.
      # @param icon [Symbol, nil] Shows this icon and keeps the text for screen readers only.
      # @param size [Symbol] +:sm+ (default) or +:md+. Set by Gustwave::Pagination.
      # @param active [Boolean] Whether the link is the current page.
      # @param options [Hash] Additional HTML attributes for the +a+ element.
      def initialize(text = nil, href:, icon: nil, size: DEFAULT, active: false, **options)
        @text = text
        @icon = icon
        select_options(size:, active:)
        @options = options.merge(href:)
      end

      # Called by Gustwave::Pagination. Each keyword is optional: a call with one
      # keyword leaves the other unchanged.
      #
      # @param list_position [Symbol, nil] +:only+, +:first+, +:middle+ or +:last+.
      # @param default_text [String, nil] The text when the link has none.
      def apply_slot_context(list_position: nil, default_text: nil)
        @default_text = default_text if default_text
        select_options(list_position:) if list_position
      end

      def before_render
        @config = attributes_for(@options)
        @config[:"aria-current"] = "page" if option_value(:active)
      end

      def call
        render Gustwave::Link.new(link_content, color: :none, underline: :none, **@config)
      end

      private

      def link_content
        return text_or_content(@text).presence || @default_text unless @icon

        label = @text || @default_text
        safe_join([ tag.span(label, class: "sr-only"), render(Gustwave::Icon.new(@icon, class: classes(:icon))) ])
      end
    end
  end
end
