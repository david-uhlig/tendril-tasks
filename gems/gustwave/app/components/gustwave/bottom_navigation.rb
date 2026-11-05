# frozen_string_literal: true

module Gustwave
  # Use BottomNavigation to render a bar at the bottom of the page with items
  # for navigating the site or running a few controls, as in Flowbite's bottom
  # navigation. The bar is fixed to the viewport by default, or sticky within
  # its container with +position: :sticky+.
  #
  # The bar lays its items out in equal columns. It also takes block content,
  # e.g. a segmented control or a player's controls, which is rendered above
  # the items. A bar with only block content has no items, so the content
  # fills it.
  #
  # Items are button or link items, set with +with_item_button+ and
  # +with_item_link+, or markup of any kind set with +with_item_generic+, e.g. a
  # call to action or a pager. Set each item's icon and label through its
  # Gustwave::BottomNavigations::Item.
  #
  # === Example
  #
  #   <%= render Gustwave::BottomNavigation.new do |navigation| %>
  #     <% navigation.with_item_button("Home", icon: :home) %>
  #     <% navigation.with_item_button("Wallet", icon: :wallet) %>
  #     <% navigation.with_item_button("Settings", icon: :cog) %>
  #     <% navigation.with_item_button("Profile", icon: :user_circle, active: true) %>
  #   <% end %>
  #
  # === Floating
  #
  # Pass +floating: true+ for a rounded bar that floats above the bottom edge,
  # as in Flowbite's application bar. The first and last items get the bar's
  # rounded ends.
  #
  # === Borders
  #
  # Pass +bordered: true+ to draw a line between the items.
  #
  # === Labels
  #
  # Pass +label_display: :tooltip+ to show each item's label as a tooltip
  # above its icon, instead of under it. An item's own +label_display:+ wins.
  #
  # === Items with other markup
  #
  # Add a call to action, a pager or any other markup with +with_item_generic+,
  # and span columns with its +class+:
  #
  #   <%= render Gustwave::BottomNavigation.new(floating: true, label_display: :tooltip) do |navigation| %>
  #     <% navigation.with_item_generic do %>
  #       <%= render Gustwave::Buttons::Default.new(pill: true, class: "w-10 h-10") do %>
  #         <%= render Gustwave::Icon.new(:plus, class: "w-4 h-4", aria: { hidden: true }) %>
  #       <% end %>
  #     <% end %>
  #   <% end %>
  #
  # === Content above the items
  #
  # Block content is rendered above the item grid, and the bar then grows to
  # fit it. Use +grid_options:+ to change the grid's columns:
  #
  #   <%= render Gustwave::BottomNavigation.new(grid_options: { class: "grid-cols-6" }) do %>
  #     <%= tag.div "Segmented control" %>
  #   <% end %>
  #
  # @param tag [Symbol] the HTML tag to render, +:div+ (default) or +:nav+. Use +:nav+ with +aria: { label: }+ for a navigation landmark.
  # @param position [Symbol] where the bar is placed, +:fixed+ (default), +:sticky+ or +:none+ to render it in the flow of the page.
  # @param floating [Boolean] whether the bar floats above the bottom edge as a rounded bar.
  # @param bordered [Boolean] whether the items are separated by a line.
  # @param label_display [Symbol] where the labels of the items are shown, +:inside+ (default) or +:tooltip+. An item's own +label_display:+ wins.
  # @param grid_options [Hash] additional HTML attributes of the grid that holds the items. Its classes win conflicts with the number of columns.
  # @param options [Hash] additional HTML attributes of the bar's element.
  #
  # @status alpha
  class BottomNavigation < Gustwave::Component
    # Grid columns per number of items, as literal classes so Tailwind generates them
    GRID_COLUMNS = {
      1 => "grid-cols-1",
      2 => "grid-cols-2",
      3 => "grid-cols-3",
      4 => "grid-cols-4",
      5 => "grid-cols-5",
      6 => "grid-cols-6",
      7 => "grid-cols-7",
      8 => "grid-cols-8"
    }.freeze

    # The HTML tag to render the bar as
    option :tag, default: :div, values: %i[div nav]

    # Where the bar is placed on the page
    base "z-50 w-full bg-white border-gray-200 dark:bg-gray-700 dark:border-gray-600"
    variant :position, default: :fixed, values: {
      fixed: "fixed bottom-0 left-0 border-t",
      sticky: "sticky bottom-0 left-0 border-t",
      none: "border-t"
    }

    # Where the labels of the items are shown
    option :label_display, default: :inside, values: %i[inside tooltip]

    # The rounded, floating bar, per position. Its items get the rounded ends at the bar's edges.
    toggle :floating, per: :position, values: {
      fixed: {
        root: "bottom-4 left-1/2 max-w-lg -translate-x-1/2 rounded-full border",
        first_item: "rounded-s-full",
        last_item: "rounded-e-full"
      },
      sticky: {
        root: "bottom-4 max-w-lg mx-auto rounded-full border",
        first_item: "rounded-s-full",
        last_item: "rounded-e-full"
      },
      none: {
        root: "max-w-lg mx-auto rounded-full border",
        first_item: "rounded-s-full",
        last_item: "rounded-e-full"
      }
    }

    # Draws a line between the items
    toggle :bordered, on: {
      item: "border-e border-gray-200 dark:border-gray-600",
      first_item: "border-s"
    }

    # Internal: on when the bar has block content above its items. The items
    # are then taller, and the bar isn't a fixed height.
    toggle :stacked, internal: true, on: { item: "p-4" }, off: { root: "h-16" }

    part :grid, "grid h-full max-w-lg mx-auto font-medium"
    part :item
    part :first_item
    part :last_item

    # Adds an item to the bar: a button, a link or markup of any kind. The
    # slot's type is set with +with_item_button+, +with_item_link+ or
    # +with_item_generic+.
    #
    # The items of a button or link take the bar's +label_display+ unless the
    # item sets its own. Pass +icon:+ for the icon, or set it through the
    # item's +icon+ slot in a block.
    #
    #   navigation.with_item_button("Home", icon: :home)
    #   navigation.with_item_link("Home", href: "/", icon: :home, active: true)
    renders_many_extensible :items, types: {
      # Adds a button item.
      #
      # @param text [String, nil] the label of the item.
      # @param icon [Symbol, nil] the name of the icon.
      # @param active [Boolean] whether the item marks the current page or section.
      # @param options [Hash] arguments of Gustwave::BottomNavigations::Item, e.g. +label_display:+, +class:+ or +data:+.
      button: ->(text = nil, icon: nil, active: false, **options) {
        Gustwave::BottomNavigations::Item.new(text, tag: :button, icon:, active:, **item_attributes(options))
      },

      # Adds a link item. Mark the current page with +active: true+.
      #
      # @param text [String, nil] the label of the item.
      # @param href [String] the URL of the item.
      # @param icon [Symbol, nil] the name of the icon.
      # @param active [Boolean] whether the item marks the current page or section.
      # @param options [Hash] arguments of Gustwave::BottomNavigations::Item.
      link: ->(text = nil, href:, icon: nil, active: false, **options) {
        Gustwave::BottomNavigations::Item.new(text, tag: :a, href:, icon:, active:, **item_attributes(options))
      },

      # Adds markup of any kind as an item, e.g. a pager or a call to action.
      # Block content is the item's markup. Its +class+ sets its column span.
      #
      # @param options [Hash] HTML attributes of the item's element.
      generic: ->(**options, &block) {
        tag.div(**configure_html_attributes(options, class: "flex items-center justify-center")) { capture(&block) if block }
      }
    }

    # @param tag [Symbol] +:div+ or +:nav+.
    # @param position [Symbol] +:fixed+, +:sticky+ or +:none+.
    # @param floating [Boolean] whether the bar floats above the bottom edge.
    # @param bordered [Boolean] whether the items are separated by a line.
    # @param label_display [Symbol] +:inside+ or +:tooltip+.
    # @param grid_options [Hash] HTML attributes of the grid that holds the items.
    # @param options [Hash] HTML attributes of the bar's element.
    def initialize(tag: DEFAULT,
                   position: DEFAULT,
                   floating: false,
                   bordered: false,
                   label_display: DEFAULT,
                   grid_options: {},
                   **options)
      select_options(tag:, position:, floating:, bordered:, label_display:)
      @html_tag = option_value(:tag)
      @grid_options = grid_options
      @options = options
    end

    def before_render
      # Evaluates the block first, so the items and the content are known
      select_options(stacked: content.present? && items.any?)

      @config = attributes_for(@options)
      @grid_config = attributes_for(:grid, configure_html_attributes(@grid_options, class: GRID_COLUMNS[items.size]))

      # Generic items are markup, so only the button and link items take the context
      items.each_with_index do |item, index|
        item.apply_slot_context(classes: item_classes(index)) if item.respond_to?(:apply_slot_context)
      end
    end

    def call
      content_tag(@html_tag, @config) do
        safe_join([ content.presence, (tag.div(**@grid_config) { safe_join(items) } if items.any?) ].compact)
      end
    end

    private

    # The item's options, with the bar's +label_display+ unless the item sets its own
    def item_attributes(options)
      configure_html_attributes(options, label_display: option_value(:label_display))
    end

    # The classes a parent gives an item: the item's part, and the edge
    # classes for the first and last item
    def item_classes(index)
      edges = []
      edges << classes(:first_item) if index.zero?
      edges << classes(:last_item) if index == items.size - 1

      merge_classes(classes(:item), *edges)
    end
  end
end
