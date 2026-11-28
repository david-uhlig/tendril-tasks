# frozen_string_literal: true

module Gustwave
  # Use List to show a series of items as an unordered or an ordered list.
  #
  # Add items with +with_item+. Each item renders as an +li+ in the list, with
  # its text or its block as the content.
  #
  # === Example
  #
  # Renders an unordered list:
  #
  #   <%= render Gustwave::List.new do |list| %>
  #     <% list.with_item "Acme Design System" %>
  #     <% list.with_item "Acme Icons" %>
  #   <% end %>
  #
  # Pass +tag: :ol+ for an ordered list, which numbers its items:
  #
  #   <%= render Gustwave::List.new(tag: :ol) do |list| %>
  #     <% list.with_item "Sign up" %>
  #     <% list.with_item "Create a project" %>
  #   <% end %>
  #
  # An item takes an icon before its text, with +icon:+ or
  # +with_leading_visual_icon+. Icons are outline; pass +theme: :solid+ for a
  # solid one, and +class:+ to color it, in a list without markers:
  #
  #   <%= render Gustwave::List.new(marker: :none) do |list| %>
  #     <% list.with_item "Included in every plan", icon: :check %>
  #     <% list.with_item "Priority support" do |item| %>
  #       <% item.with_leading_visual_icon :check_circle, theme: :solid, class: "text-green-500 dark:text-green-400" %>
  #     <% end %>
  #   <% end %>
  #
  # An item without text takes its block as its content, e.g. a nested list.
  # Pass +nested: true+ to indent the nested list:
  #
  #   <%= render Gustwave::List.new do |list| %>
  #     <% list.with_item do %>
  #       Acme Design System
  #       <%= render Gustwave::List.new(tag: :ol, nested: true) do |nested| %>
  #         <% nested.with_item "Tokens" %>
  #         <% nested.with_item "Components" %>
  #       <% end %>
  #     <% end %>
  #   <% end %>
  #
  # Pass +divided: true+ to separate the items with lines:
  #
  #   <%= render Gustwave::List.new(divided: true) do |list| %>
  #     <% list.with_item "Acme Design System" %>
  #     <% list.with_item "Acme Icons" %>
  #   <% end %>
  #
  # Pass +orientation: :horizontal+ to show the items in a row, wrapping onto
  # more lines when needed. With +marker: :none+ the row shows no markers:
  #
  #   <%= render Gustwave::List.new(orientation: :horizontal, marker: :none) do |list| %>
  #     <% list.with_item do %>
  #       <%= render Gustwave::Link.new("Privacy", href: "/privacy") %>
  #     <% end %>
  #     <% list.with_item do %>
  #       <%= render Gustwave::Link.new("Terms", href: "/terms") %>
  #     <% end %>
  #   <% end %>
  #
  # +marker: :none+ renders no marker classes and adds <tt>role="list"</tt>,
  # which keeps the list announced as a list in screen readers, unless you pass
  # a +role+ yourself.
  #
  # A nested list keeps the default text color. Pass +color: :none+ to the
  # nested list to inherit the color of its parent.
  #
  # The list doesn't set its width.
  #
  # @see Gustwave::List::Item
  #
  # @status alpha
  class List < Gustwave::Component
    # The HTML tag: an unordered or an ordered list
    option :tag, default: :ul, values: %i[ul ol]

    # The marker per tag, when no marker is given
    derive :default_marker, from: :tag, values: { ul: :disc, ol: :decimal }

    # The marker of each item. +:none+ adds no classes; Tailwind's preflight already hides the markers.
    variant :marker, default: :disc, values: {
      disc: "list-disc list-inside",
      decimal: "list-decimal list-inside"
    }

    variant :color, default: :default, values: { default: "text-gray-500 dark:text-gray-400" }

    variant :orientation, default: :vertical, allow_none: false, values: {
      vertical: "space-y-1",
      horizontal: "flex flex-wrap items-center"
    }

    toggle :nested, "ps-5 mt-2"
    toggle :divided, "space-y-0 divide-y divide-gray-200 dark:divide-gray-700"

    # @param options [Hash] the arguments of Gustwave::List::Item, e.g. +icon:+.
    renders_many_extensible :items, ->(text = nil, **options) { Gustwave::List::Item.new(text, **options) }

    # @param tag [Symbol] +:ul+ (default) for an unordered list, +:ol+ for an ordered one. Valid values are +:ul+ and +:ol+.
    # @param marker [Symbol] the marker of each item. Defaults to +:disc+ for a +:ul+ and +:decimal+ for an +:ol+. Valid values are +:disc+, +:decimal+ and +:none+, which shows no marker.
    # @param color [Symbol] the text color. Defaults to +:default+, gray. +:none+ adds no color classes.
    # @param orientation [Symbol] +:vertical+ (default) stacks the items, +:horizontal+ lays them out in a row. Valid values are +:vertical+ and +:horizontal+.
    # @param nested [Boolean] whether the list is indented inside an item. Defaults to +false+.
    # @param divided [Boolean] whether the items are separated by lines. Defaults to +false+.
    # @param options [Hash] the HTML attributes of the list element. A list without markers gets <tt>role="list"</tt>, unless a +role+ is given.
    def initialize(tag: DEFAULT, marker: DEFAULT, color: DEFAULT, orientation: DEFAULT, nested: false, divided: false, **options)
      select_options(tag:)

      marker = derived_value(:default_marker) if marker.nil? || marker.equal?(DEFAULT)
      select_options(marker:, color:, orientation:, nested:, divided:)

      # Safari drops the list role of a list without markers
      options = { role: "list", **options } if option_value(:marker) == :none
      @options = attributes_for(options)
    end

    def before_render
      items.each_with_index do |item, index|
        next unless item.respond_to?(:apply_slot_context)

        item.apply_slot_context(orientation: option_value(:orientation), list_position: option_value(:divided) ? list_position(index) : nil)
      end
    end

    def call
      content_tag(option_value(:tag), **@options) { slots_and_content(items) }
    end

    private

    # :only for a single item, otherwise :first, :middle or :last
    def list_position(index)
      return :only if items.size == 1
      return :first if index.zero?
      return :last if index == items.size - 1

      :middle
    end
  end
end
