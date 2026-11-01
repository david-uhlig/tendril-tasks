# frozen_string_literal: true

module Gustwave
  # Use Timeline to render a list of events along a line, as in Flowbite's
  # timeline. Each item has optional slots for a marker, a date, a title and a
  # body, in that order. Block content renders after them, e.g. a call to action.
  #
  # An item shows the date before the title. To put the title first, as some of
  # Flowbite's examples do, pass the date and title as block content instead.
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Timeline.new do |timeline| %>
  #     <% timeline.with_item do |item| %>
  #       <% item.with_date "February 2022" %>
  #       <% item.with_title "Application UI code in Tailwind CSS" %>
  #       <% item.with_body "Get access to over 20+ pages." %>
  #     <% end %>
  #   <% end %>
  #
  # === Icon Marker, Badge and Call to Action
  #
  #   <%= render Gustwave::Timeline.new do |timeline| %>
  #     <% timeline.with_item do |item| %>
  #       <% item.with_marker_icon :calendar_month %>
  #       <% item.with_date Date.new(2022, 1, 13) %>
  #       <% item.with_title(class: "flex items-center mb-1") do %>
  #         Flowbite Application UI v2.0.0
  #         <%= render Gustwave::Badge.new("Latest", class: "ms-3") %>
  #       <% end %>
  #       <% item.with_body "Get started with dozens of web components." %>
  #       <%= render Gustwave::Buttons::Default.new("Download ZIP", tag: :a, href: "#", color: :alternative) %>
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
  #       <% item.with_title "Flowbite Library v1.0.0" %>
  #     <% end %>
  #   <% end %>
  #
  # === Activity Log
  #
  # Flowbite's activity log is a composition: image markers, with a
  # Gustwave::Card as block content.
  #
  #   <% timeline.with_item do |item| %>
  #     <% item.with_marker_image "/avatar.png", alt: "Bonnie Green" %>
  #     <%= render Gustwave::Card.new(class: "max-w-none") do %>
  #       Bonnie moved Jese Leos to Funny Group
  #     <% end %>
  #   <% end %>
  #
  # @param orientation [Symbol] +:vertical+ (default) or +:horizontal+. The items take the timeline's orientation.
  # @param options [Hash] HTML attributes for the +<ol>+ element.
  class Timeline < Gustwave::Component
    variant :orientation, default: :vertical, values: {
      vertical: "relative border-s border-gray-200 dark:border-gray-700",
      horizontal: "items-center sm:flex"
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
      part :date, "block mb-1 text-sm font-normal leading-none text-gray-400 dark:text-gray-500"
      # Gustwave::Heading drops its colors with size: :none, so they are here
      part :title, "text-lg font-semibold text-gray-900 dark:text-white"
      # Spaces the body from any block content after it
      part :body, "mb-4 last:mb-0 text-base font-normal"

      variant :orientation, default: :vertical, values: {
        vertical: {
          root: "mb-10 ms-4 last:mb-0",
          dot: "absolute w-3 h-3 bg-gray-200 rounded-full mt-1.5 -start-1.5 border border-white dark:border-gray-900 dark:bg-gray-700",
          marker: "absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -start-3 ring-8 ring-white dark:ring-gray-900 dark:bg-blue-900"
        },
        horizontal: {
          root: "relative mb-6 sm:mb-0",
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

      # @param value [Date, Time, String, nil] the date. A date or time is localized and sets +datetime+. Pass a block for other content.
      # @param datetime [String, nil] the +datetime+ attribute.
      # @param options [Hash] HTML attributes for the +<time>+ element.
      renders_one_extensible :date, ->(value = nil, datetime: nil, **options, &block) {
        if value.respond_to?(:iso8601)
          datetime ||= value.iso8601
          value = I18n.l(value)
        end
        tag.time(value || capture(&block), datetime:, **attributes_for(:date, options))
      }

      # @param text [String, nil] the title. Pass a block for other content.
      # @param tag [Symbol] the heading level.
      # @param options [Hash] the arguments of Gustwave::Heading.
      renders_one_extensible :title, ->(text = nil, tag: :h3, **options) {
        Gustwave::Heading.new(text, tag:, size: :none, **attributes_for(:title, options))
      }

      # @param text [String, nil] the body. Pass a block for other content.
      # @param options [Hash] the arguments of Gustwave::Paragraph.
      renders_one_extensible :body, ->(text = nil, **options) {
        Gustwave::Paragraph.new(text, **attributes_for(:body, options))
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
        safe_join([ marker_or_dot, details ])
      end

      def horizontal
        safe_join([
          tag.div(safe_join([ marker_or_dot, tag.div(class: classes(:connector)) ]), class: classes(:track)),
          tag.div(details, class: classes(:content))
        ])
      end

      def marker_or_dot
        return tag.span(marker, class: classes(:marker)) if marker?

        tag.div(class: classes(:dot), aria: { hidden: true })
      end

      def details
        safe_join([ date, title, body, content ].compact)
      end
    end
  end
end
