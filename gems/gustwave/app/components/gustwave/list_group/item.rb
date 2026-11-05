# frozen_string_literal: true

module Gustwave
  class ListGroup < Gustwave::Component
    # One item of a Gustwave::ListGroup, set with +with_item_text+,
    # +with_item_link+ or +with_item_button+. The list sets the item's position,
    # which rounds its corners and draws its separator, and whether it sits in a
    # list or a group.
    #
    # A link or button item is interactive: it shows hover and focus states.
    # Pass +active: true+ to mark the current item, which also sets
    # +aria-current="true"+, or +disabled: true+ to disable a button.
    #
    # Pass +icon+ to show an icon before the text. The icon is decorative and
    # hidden from screen readers.
    #
    # @status alpha
    class Item < Gustwave::Component
      # Text items are li elements in a list and div elements in a group. Set by
      # Gustwave::ListGroup through +apply_slot_context+.
      variant :tag, default: :li, values: {
        li: nil,
        div: nil,
        a: "block cursor-pointer",
        button: "font-medium text-left rtl:text-right cursor-pointer"
      }

      # Selected by Gustwave::ListGroup
      variant :list_position, default: :only, internal: true, values: {
        only: "rounded-lg",
        first: "rounded-t-lg border-b border-gray-200 dark:border-gray-600",
        middle: "border-b border-gray-200 dark:border-gray-600",
        last: "rounded-b-lg"
      }

      base "w-full px-4 py-2"

      # Hover and focus states, while the item can be pressed
      toggle :hover, "hover:bg-gray-100 hover:text-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-700 focus:text-blue-700 dark:hover:bg-gray-600 dark:hover:text-white dark:focus:ring-gray-500 dark:focus:text-white",
             internal: true, unless: { tag: %i[li div] }

      toggle :active, "text-white bg-blue-700 dark:bg-gray-800", unless: { tag: %i[li div] }

      toggle :disabled, "bg-gray-100 cursor-not-allowed dark:bg-gray-600 dark:text-gray-400", unless: { tag: %i[li div a] }

      # Selected by the item when it has an icon
      toggle :has_icon, "relative inline-flex items-center focus:z-10", internal: true

      renders_one_extensible :icon, ->(name, **options) {
        Gustwave::Icon.new(name, **configure_html_attributes(options, class: "w-3 h-3 me-2.5", aria: { hidden: true }))
      }

      # @param text [String, nil] The item text. Takes precedence over block content.
      # @param icon [Symbol, nil] Shows this icon before the text.
      # @param tag [Symbol] +:li+ (default), +:div+, +:a+ or +:button+. Set by Gustwave::ListGroup for text items.
      # @param active [Boolean] Whether this is the current item.
      # @param disabled [Boolean] Whether a button item is disabled.
      # @param options [Hash] HTML attributes for the item element, e.g. +href:+ for a link.
      def initialize(text = nil, icon: nil, tag: DEFAULT, active: false, disabled: false, **options)
        @text = text
        with_icon(icon) if icon
        select_options(tag:, active:, disabled:)
        @options = options
      end

      # Called by Gustwave::ListGroup. Each keyword is optional.
      #
      # @param list_position [Symbol, nil] +:only+, +:first+, +:middle+ or +:last+.
      # @param container [Symbol, nil] +:list+ inside a +ul+, or +:group+ inside a +div+. A text item becomes a +div+ in a group.
      def apply_slot_context(list_position: nil, container: nil, **)
        select_options(list_position:) if list_position
        select_options(tag: :div) if container == :group && option_value(:tag) == :li
      end

      def before_render
        # Reading the icon evaluates the block, so the icon is known before the classes are set
        select_options(has_icon: icon?, hover: !option_value(:active) && !option_value(:disabled))

        @config = attributes_for(@options)
        case option_value(:tag)
        when :button
          @config[:type] = "button"
          @config[:disabled] = true if option_value(:disabled)
          @config[:"aria-current"] = "true" if option_value(:active)
        when :a
          @config[:"aria-current"] = "true" if option_value(:active)
        end
      end

      def call
        content_tag(option_value(:tag), **@config) do
          safe_join([ icon, text_or_content(@text) ].compact)
        end
      end
    end
  end
end
