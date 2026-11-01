# frozen_string_literal: true

module Gustwave
  # Use Timeline to render a list of events along a line, as in Flowbite's
  # timeline. The timeline draws the line and places each item's marker. What an
  # item shows is up to its block, composed from other components.
  #
  # A vertical item's dot lines up with a first line of text 24px tall. Keep a
  # date in that first line inline, as below, not +block+ with +leading-none+.
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Timeline.new do |timeline| %>
  #     <% timeline.with_item do %>
  #       <%= time_tag Date.new(2022, 2, 1), "February 2022", class: "text-sm font-normal leading-none text-gray-400 dark:text-gray-500" %>
  #       <%= render Gustwave::Heading.new("Application UI code in Tailwind CSS", tag: :h3, size: :xs, class: "text-lg") %>
  #       <%= render Gustwave::Paragraph.new("Get access to over 20+ pages.") %>
  #     <% end %>
  #   <% end %>
  #
  # === Markers
  #
  # An item without a marker shows a dot. Set an icon or an image as its marker
  # with +with_marker_icon+ or +with_marker_image+:
  #
  #   <%= render Gustwave::Timeline.new do |timeline| %>
  #     <% timeline.with_item do |item| %>
  #       <% item.with_marker_icon :calendar_month %>
  #       <%= render Gustwave::Heading.new("Flowbite Figma v1.3.0", tag: :h3, size: :xs, class: "text-lg") %>
  #     <% end %>
  #     <% timeline.with_item do |item| %>
  #       <% item.with_marker_image "/avatar.png", alt: "Bonnie Green" %>
  #       <%= render Gustwave::Card.new(class: "max-w-none") do %>
  #         Bonnie moved Jese Leos to Funny Group
  #       <% end %>
  #     <% end %>
  #   <% end %>
  #
  # === Horizontal
  #
  # Items sit side by side from the +sm+ breakpoint up, joined by a line:
  #
  #   <%= render Gustwave::Timeline.new(orientation: :horizontal) do |timeline| %>
  #     <% timeline.with_item do |item| %>
  #       <% item.with_marker_icon :calendar_month %>
  #       <%= render Gustwave::Heading.new("Flowbite Library v1.0.0", tag: :h3, size: :xs, class: "text-lg") %>
  #     <% end %>
  #   <% end %>
  #
  # @param orientation [Symbol] +:vertical+ (default) or +:horizontal+. The items take the timeline's orientation.
  # @param options [Hash] HTML attributes for the +<ol>+ element.
  class Timeline < Gustwave::Component
    variant :orientation, default: :vertical, values: {
      vertical: "relative border-s border-gray-200 dark:border-gray-700",
      horizontal: "sm:flex"
    }

    # @param options [Hash] the arguments of Gustwave::Timeline::Item
    renders_many_extensible :items, ->(**options) {
      Gustwave::Timeline::Item.new(orientation: option_value(:orientation), **options)
    }

    def initialize(orientation: DEFAULT, **options)
      select_options(orientation:)
      @options = attributes_for(options)
    end

    def call
      tag.ol(**@options) { slots_and_content(items) }
    end

    # An item of a Gustwave::Timeline, set with +with_item+.
    class Item < Gustwave::Component
      part :dot
      part :marker
      part :track
      part :connector
      part :content

      variant :orientation, default: :vertical, values: {
        vertical: {
          root: "mb-10 ms-4 last:mb-0",
          dot: "absolute w-3 h-3 bg-gray-200 rounded-full mt-1.5 -start-1.5 border border-white dark:border-gray-900 dark:bg-gray-700",
          marker: "absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -start-3 ring-8 ring-white dark:ring-gray-900 dark:bg-blue-900"
        },
        horizontal: {
          # Equal columns, so items with more text don't squeeze the others
          root: "relative mb-6 last:mb-0 sm:mb-0 sm:flex-1",
          # As tall as a marker, so items with a dot line up with items with a marker
          track: "flex items-center h-6",
          dot: "z-10 w-3 h-3 bg-gray-200 rounded-full border border-white dark:border-gray-900 dark:bg-gray-700 shrink-0",
          marker: "z-10 flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full ring-0 ring-white dark:bg-blue-900 sm:ring-8 dark:ring-gray-900 shrink-0",
          connector: "hidden sm:flex w-full bg-gray-200 h-0.5 dark:bg-gray-700",
          content: "mt-3 sm:pe-8"
        }
      }

      # Set by the component: a marker is wider than a dot, so a vertical item indents further
      toggle :has_marker, "ms-6", internal: true, unless: { orientation: :horizontal }

      renders_one_extensible :marker, types: {
        icon: ->(name, theme: :solid, **options) {
          Gustwave::Icon.new(name, theme:, **configure_html_attributes(options, class: "w-2.5 h-2.5 text-blue-800 dark:text-blue-300"))
        },
        image: ->(src, alt:, **options) {
          Gustwave::Avatar.new(src:, alt:, size: :xs, **configure_html_attributes(options, class: "shadow-lg"))
        }
      }

      # @param orientation [Symbol] +:vertical+ (default) or +:horizontal+. Set by Gustwave::Timeline.
      # @param options [Hash] HTML attributes for the +<li>+ element.
      def initialize(orientation: DEFAULT, **options)
        select_options(orientation:)
        @options = options
      end

      def before_render
        # Must select here to know whether the marker slot was set
        select_options(has_marker: marker?)
        @config = attributes_for(@options)
      end

      def call
        tag.li(**@config) { option_value(:orientation) == :horizontal ? horizontal : vertical }
      end

      private

      def vertical
        safe_join([ marker_or_dot, content ].compact)
      end

      def horizontal
        safe_join([
          tag.div(safe_join([ marker_or_dot, tag.div(class: classes(:connector)) ]), class: classes(:track)),
          tag.div(content, class: classes(:content))
        ])
      end

      def marker_or_dot
        return tag.span(marker, class: classes(:marker)) if marker?

        tag.div(class: classes(:dot), aria: { hidden: true })
      end
    end
  end
end
