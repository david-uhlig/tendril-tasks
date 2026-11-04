# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Menus
      # Use List to render a menu list with a header, links, dividers, dropdowns, and a footer
      #
      # Slot structure (all optional)
      # - +header+ (any HTML markup)
      # - \List items:
      #   - +link+ (LinkButton), set with +with_item_link+
      #   - +generic+ (any HTML markup)
      #   - +divider+ (Divider)
      #   - +dropdown+ (Dropdown)
      # - +footer+ (any HTML markup)
      #
      # Block content renders after the list items and before the footer. Blank block content,
      # such as a block that only sets slots, renders nothing.
      #
      # @status alpha
      class List < Gustwave::Dropdowns::Menus::Base
        # The HTML tag of the list, set with +tag:+ in +list_options:+
        option :list_tag, default: :ul, values: %i[ul ol]

        part :list, "py-2 text-sm text-gray-700 dark:text-gray-200"

        part :list_item, "flex items-center gap-1.5 w-full px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white whitespace-nowrap"

        renders_many_extensible :items, types: {
          generic: ->(&block) { capture(&block) },
          link: Gustwave::Dropdowns::MenuItems::LinkButton,
          divider: Gustwave::Dropdowns::MenuItems::Divider,
          dropdown: Gustwave::Dropdowns::MenuItems::Dropdown
        }

        # @param id [String] the id attribute for the dropdown menu. Must match the id attribute called by the triggering element.
        # @param content_for [Symbol, nil] the name of the content area to render the menu. If +nil+, the menu is rendered right after the triggering element.
        # @param tag [Symbol] HTML tag to use for the dropdown menu. Default: +div+.
        # @param list_options [Hash] HTML attributes passed to the list element, and its +tag+ (+ul+ or +ol+), e.g. +{ tag: :ol, class: "py-1" }+ (optional).
        # @param options [Hash] additional HTML attributes passed to the surrounding HTML element.
        def initialize(id:, content_for: nil, tag: DEFAULT, list_options: {}, **options)
          super(nil, content_for:, tag:, id:, **options)
          list_options = list_options.symbolize_keys
          select_options(list_tag: list_options.fetch(:tag, DEFAULT))
          @list_tag = option_value(:list_tag)
          @list_config = attributes_for(:list, list_options.except(:tag))
        end

        def call
          content_for_wrapper do
            content_tag menu_tag, **config do
              safe_join([ header, list_with_items, content.presence, footer ])
            end
          end
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
