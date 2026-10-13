# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Menus
      # Use List to render a menu list with a header, links, dividers, dropdowns, and a footer
      #
      # Slot structure (all optional)
      # - +header+ (any HTML markup)
      # - \List items:
      #   - +item+ (LinkButton), alias: +link+
      #   - +generic+ (any HTML markup)
      #   - +divider+ (Divider)
      #   - +dropdown+ (Dropdown)
      # - +footer+ (any HTML markup)
      #
      # Block content gets ignored.
      class List < Gustwave::Dropdowns::Menus::Base
        style :list_base, "py-2 text-sm text-gray-700 dark:text-gray-200"

        style :list_item_base, "flex items-center gap-1.5 w-full px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white whitespace-nowrap"

        renders_many :items, types: {
          generic: ->(&block) { capture(&block) },
          item: Gustwave::Dropdowns::MenuItems::LinkButton,
          divider: Gustwave::Dropdowns::MenuItems::Divider,
          dropdown: Gustwave::Dropdowns::MenuItems::Dropdown
        }
        alias item with_item_item
        alias link with_item_item
        alias generic_item with_item_generic
        alias divider with_item_divider
        alias dropdown with_item_dropdown

        # @param id [String] the id attribute for the dropdown menu. Must match the id attribute called by the triggering element.
        # @param content_for [Symbol, nil] the name of the content area to render the menu. If +nil+, the menu is rendered right after the triggering element.
        # @param tag [Symbol] HTML tag to use for the dropdown menu. Default: +div+.
        # @param options [Hash] additional HTML attributes passed to the surrounding HTML element. Call +configure_list+ to configure the list element (optional).
        def initialize(id:, content_for: nil, tag: :div, **options)
          super(text, content_for:, tag:, id:, **options)
          configure_list
        end

        def call
          content_for_wrapper do
            content_tag menu_tag, **config do
              safe_join([ header_slot, list_with_items, footer_slot ])
            end
          end
        end

        # Configure the surrounding HTML list element
        #
        # @param tag [Symbol] the tag of the HTML list element, usually +ul+ or +ol+.
        # @param options [Hash] additional HTML attributes passed to the list element.
        def configure_list(tag: :ul, **options)
          @list_tag = tag
          @list_config = configure_html_attributes(
            options,
            class: styles(list_base: true)
          )
        end

        private
        attr_reader :list_tag, :list_config

        def list_with_items
          content_tag list_tag, **list_config do
            safe_join([ items.map { |element| tag.li { element.to_s } } ])
          end
        end

        def flex_grow(text = nil, &block)
          text || capture(&block)
        end
      end
    end
  end
end
