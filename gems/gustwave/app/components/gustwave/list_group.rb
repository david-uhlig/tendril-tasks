# frozen_string_literal: true

module Gustwave
  # Use ListGroup to show a series of items in one bordered box, like a
  # sidebar menu, as in Flowbite's list group. The list rounds its outer corners
  # and separates the items with a border, whatever the item types are.
  #
  # Add items with +with_item_text+, +with_item_link+ or +with_item_button+. A
  # text item renders as an +li+ in a +ul+. As soon as the list holds a link or
  # a button, the list renders as a +div+ and its text items as +div+s, so the
  # markup stays valid.
  #
  # The list doesn't set its width. Pass +class: "w-48"+ or another width.
  #
  # === Example
  #
  # Renders a menu with the first link active and a disabled button:
  #
  #   <%= render Gustwave::ListGroup.new(class: "w-48") do |list_group| %>
  #     <% list_group.with_item_link("Profile", href: "/profile", active: true) %>
  #     <% list_group.with_item_link("Settings", href: "/settings") %>
  #     <% list_group.with_item_button("Download", disabled: true) %>
  #   <% end %>
  #
  # Items keep the order they are set in. Pass +icon:+ to show an icon before
  # the text:
  #
  #   <%= render Gustwave::ListGroup.new(class: "w-48") do |list_group| %>
  #     <% list_group.with_item_button("Profile", icon: :user_circle) %>
  #     <% list_group.with_item_button("Messages", icon: :messages) %>
  #   <% end %>
  #
  # Items take leading and trailing visuals, see Gustwave::Visuals, e.g. a
  # count at the end of the item:
  #
  #   <%= render Gustwave::ListGroup.new(class: "w-48") do |list_group| %>
  #     <% list_group.with_item_link("Messages", href: "/messages") do |item| %>
  #       <% item.with_trailing_visual_renderable(Gustwave::Badge.new("3", class: "ms-auto")) %>
  #     <% end %>
  #   <% end %>
  #
  # An item takes its content from its block when it has no text.
  #
  # @see Gustwave::ListGroup::Item
  #
  # @status alpha
  class ListGroup < Gustwave::Component
    base "text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-lg dark:bg-gray-700 dark:border-gray-600 dark:text-white"

    # @param text [String, nil] The item text. Takes precedence over block content.
    # @param options [Hash] the arguments of Gustwave::ListGroup::Item, e.g. +icon:+.
    renders_many_extensible :items, types: {
      text: ->(text = nil, **options) { Gustwave::ListGroup::Item.new(text, **options) },
      link: ->(text = nil, href:, active: false, **options) {
        Gustwave::ListGroup::Item.new(text, **options, tag: :a, href:, active:)
      },
      button: ->(text = nil, active: false, disabled: false, **options) {
        Gustwave::ListGroup::Item.new(text, **options, tag: :button, active:, disabled:)
      }
    }, renderable: true

    # @param options [Hash] HTML attributes for the list element, e.g. +class: "w-48"+.
    def initialize(**options)
      @options = options
    end

    def before_render
      # A list of text items is a ul of li elements. A link or button makes it a div.
      @root_tag = items.all? { |item| item.respond_to?(:option_value) && item.option_value(:tag) == :li } ? :ul : :div
      @config = attributes_for(@options)

      items.each_with_index do |item, index|
        next unless item.respond_to?(:apply_slot_context)

        item.apply_slot_context(list_position: list_position(index), container: @root_tag == :ul ? :list : :group)
      end
    end

    def call
      content_tag(@root_tag, **@config) { slots_and_content(items) }
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
