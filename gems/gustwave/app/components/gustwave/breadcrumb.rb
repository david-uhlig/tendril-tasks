# frozen_string_literal: true

module Gustwave
  # Use Breadcrumb to show where the current page sits in a hierarchy, as in
  # Flowbite's breadcrumbs. It joins its items with a separator and marks the
  # last item as the current page with +aria-current="page"+.
  #
  # Add an item with +with_item+. Pass it an +href+ to link it. The content
  # block renders after the list of items, e.g. a dropdown on the right.
  #
  # === Example
  #
  # Renders a breadcrumb with a solid background:
  #
  #   <%= render Gustwave::Breadcrumb.new(solid: true) do |breadcrumb| %>
  #     <% breadcrumb.with_item("Home", href: "/", icon: :home) %>
  #     <% breadcrumb.with_item("Projects", href: "/projects") %>
  #     <% breadcrumb.with_item("Flowbite") %>
  #   <% end %>
  #
  # Pass a block to an item for other content, e.g. a dropdown:
  #
  #   <%= render Gustwave::Breadcrumb.new(separator: :slash) do |breadcrumb| %>
  #     <% breadcrumb.with_item do %>
  #       <%= render Gustwave::Dropdown.new("flowbite.com") %>
  #     <% end %>
  #   <% end %>
  #
  # @param solid [Boolean] Whether the breadcrumb has a bordered, solid background.
  # @param separator [Symbol] The separator between items, +:chevron+ (default) or +:slash+.
  # @param list_options [Hash] HTML attributes for the +ol+ element, e.g. +class+ to change its margins.
  # @param options [Hash] HTML attributes for the +nav+ element, e.g. +aria: { label: "Tasks" }+.
  #
  # @status alpha
  class Breadcrumb < Gustwave::Component
    base "flex"

    toggle :solid, "px-5 py-3 text-gray-700 border border-gray-200 rounded-lg bg-gray-50 dark:bg-gray-800 dark:border-gray-700"

    part :list, "inline-flex items-center"

    option :separator, default: :chevron, values: %i[chevron slash]

    # Chevrons need space around them. A slash brings its own margins, so
    # the list has none, as in Flowbite.
    toggle :spaced, "space-x-1 md:space-x-2 rtl:space-x-reverse", part: :list, internal: true

    # @param text [String, nil] The item text. Takes precedence over block content.
    # @param href [String, nil] The URL the item links to. Leave it out for the current page.
    # @param icon [Symbol, nil] An icon shown before the text.
    # @param options [Hash] the arguments of Gustwave::Breadcrumb::Item, e.g. HTML attributes for its +li+ element.
    renders_many_extensible :items, ->(text = nil, href: nil, icon: nil, **options) {
      Gustwave::Breadcrumb::Item.new(text, href:, icon:, **options)
    }

    # @param solid [Boolean] Whether the breadcrumb has a bordered, solid background.
    # @param separator [Symbol] +:chevron+ (default) or +:slash+.
    # @param list_options [Hash] HTML attributes for the +ol+ element.
    # @param options [Hash] HTML attributes for the +nav+ element.
    def initialize(solid: DEFAULT, separator: DEFAULT, list_options: {}, **options)
      select_options(solid:, separator:)
      select_options(spaced: option_value(:separator) == :chevron)
      @list_options = list_options
      @options = options
    end

    def before_render
      # t needs the view context, so this can't happen in the constructor
      @config = attributes_for(configure_html_attributes(@options, aria: { label: t(".label") }))
      last = items.size - 1
      items.each_with_index do |item, index|
        item.apply_slot_context(
          position: index.zero? ? :first : :other,
          current: index == last,
          separator: option_value(:separator)
        )
      end
    end

    def call
      list = tag.ol(**configure_html_attributes(@list_options, class: classes(:list))) do
        safe_join(items.map(&:to_s))
      end
      tag.nav(**@config) { safe_join([ list, content ]) }
    end
  end
end
