# frozen_string_literal: true

module Gustwave
  module Containers
    # Use ResponsiveHorizontalScroll to create a container that scrolls
    # horizontally on mobile device viewports and wraps its elements on larger
    # viewports.
    class ResponsiveHorizontalScroll < Gustwave::Component
      base "flex flex-nowrap overflow-x-auto touch-pan-x gap-2 pb-2"

      # The HTML tag of the container
      option :tag, default: :div, values: %i[div span ul ol]

      # The HTML tag of the +item+ slot per container tag
      derive :item_tag, from: :tag, values: { div: :div, span: :span, ul: :li, ol: :li }

      # Use Tailwind CSS mobile breakpoints to determine when to wrap the items
      # instead of scrolling them horizontally.
      variant :breakpoint, default: :md, values: {
        sm: "sm:flex-wrap sm:overflow-visible sm:py-0",
        md: "md:flex-wrap md:overflow-visible md:py-0",
        lg: "lg:flex-wrap lg:overflow-visible lg:py-0",
        xl: "xl:flex-wrap xl:overflow-visible xl:py-0",
        "2xl": "2xl:flex-wrap 2xl:overflow-visible 2xl:py-0"
      }

      # Use snap to control the scrolling behavior on mobile devices.
      # @see https://v3.tailwindcss.com/docs/scroll-snap-align
      variant :snap, default: :none, values: {
        start: "snap-x snap-start",
        center: "snap-x snap-center",
        end: "snap-x snap-end"
      }

      # Use the +item+ slot to provide items for the container
      #
      # Convenience method to make it look less awkward in templates when using
      # list containers. The +item+ tag resolves automatically based on the
      # container tag.
      #
      # === Example
      # Instead of defining the container like this:
      #
      #   <%= render Gustwave::Containers::ResponsiveHorizontalScroll.new(tag: :ul) do %>
      #     <li>Item 1</li>
      #     <li>Item 2</li>
      #     <li>Item 3</li>
      #   <% end %>
      #
      # You can use the +item+ slot, which automatically resolves the correct
      # item tag:
      #
      #   <%= render Gustwave::Containers::ResponsiveHorizontalScroll.new(tag: :ul) do %>
      #     <% it.item do %>Item 1<% end %>
      #     <% it.item do %>Item 2<% end %>
      #     <% it.item do %>Item 3<% end %>
      #   <% end %>
      #
      # @param text [String] the text to display inside the item. Takes precedent over block content.
      # @param tag [Symbol] the HTML tag for the item. Resolved automatically based on the container tag if not provided.
      # @param options [Hash] additional options for the HTML tag.
      renders_many_extensible :items, ->(text = nil, tag: nil, **options, &block) do
        item_tag = tag || derived_value(:item_tag)
        config = configure_html_attributes(options)
        content_tag item_tag, config do
          text || capture(&block)
        end
      end
      alias item with_item

      # @param tag [Symbol] the HTML tag for the container.
      # @param breakpoint [Symbol] the breakpoint at and above which the container wraps its items. Use t-shirt sizes from :sm to +:"2xl"+
      # @param snap [Symbol] the scroll snap behavior on mobile devices. Use +:none+, +:start+, +:center+, or +:end+. See: https://v3.tailwindcss.com/docs/scroll-snap-align
      # @param options [Hash] additional options for the HTML tag.
      def initialize(tag: DEFAULT, breakpoint: DEFAULT, snap: DEFAULT, **options)
        select_options(tag:, breakpoint:, snap:)
        @tag = option_value(:tag)
        @config = attributes_for(options)
      end

      def call
        content_tag tag, **config do
          slots_and_content(items)
        end
      end

      private
      attr_reader :config, :tag
    end
  end
end
