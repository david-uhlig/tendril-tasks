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
    # Renders leading and trailing visuals, see Gustwave::Visuals, e.g. a
    # count after the text:
    #
    #   list_group.with_item_link("Messages", href: "/messages") do |item|
    #     item.with_trailing_visual_renderable(Gustwave::Badge.new("3", class: "ms-auto"))
    #   end
    #
    # +icon:+ is shorthand for +with_leading_visual_icon+ with a solid icon, as
    # in Flowbite. +with_leading_visual_icon+ itself defaults to outline, as in
    # Gustwave's other components. Visuals are decorative and hidden from
    # screen readers.
    #
    # @status alpha
    class Item < Gustwave::Component
      include Gustwave::Visuals

      # Text items are li elements in a list and div elements in a group. Set by
      # Gustwave::ListGroup through +apply_slot_context+.
      option :tag, default: :li, values: %i[li div a button]

      # Selected from +tag+: text items are static, links and buttons interactive
      variant :kind, default: :static, internal: true, values: {
        static: "",
        link: "block cursor-pointer",
        button: "font-medium text-left rtl:text-right cursor-pointer"
      }

      KINDS = { li: :static, div: :static, a: :link, button: :button }.freeze
      private_constant :KINDS

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
             internal: true, unless: { kind: :static }

      toggle :active, "text-white bg-blue-700 dark:bg-gray-800", unless: { kind: :static }

      toggle :disabled, "bg-gray-100 cursor-not-allowed dark:bg-gray-600 dark:text-gray-400", unless: { kind: %i[static link] }

      # Gustwave::Visuals needs a size. Items have one. Gustwave's icons leave 3
      # units of their 24x24 viewBox empty on each side. At w-4 the glyph is as
      # large as Flowbite's w-3 icon, and the margins and the gap make up for
      # the empty part, which leaves Flowbite's 10px between icon and text.
      variant :size, default: :sm, internal: true, values: {
        sm: { root: "", visual: "w-4 h-4 -mx-0.5 -my-0.5" }
      }

      derive :indicator_size, from: :size, values: { sm: :sm }

      # Selected by the item when it has a visual. Declared after +kind+, so
      # inline-flex wins over a link's block, and after Visuals' has_visual, so
      # gap-2.5 wins over its gap.
      toggle :has_visual_item, "relative inline-flex gap-2.5 focus:z-10", internal: true

      # @param text [String, nil] The item text. Takes precedence over block content.
      # @param icon [Symbol, nil] Shows this solid icon before the text. Shorthand for +with_leading_visual_icon+.
      # @param tag [Symbol] +:li+ (default), +:div+, +:a+ or +:button+. Set by Gustwave::ListGroup for text items.
      # @param active [Boolean] Whether this is the current item.
      # @param disabled [Boolean] Whether a button item is disabled.
      # @param options [Hash] HTML attributes for the item element, e.g. +href:+ for a link.
      def initialize(text = nil, icon: nil, tag: DEFAULT, active: false, disabled: false, **options)
        @text = text
        with_leading_visual_icon(icon, theme: :solid) if icon
        select_options(tag:, active:, disabled:)
        select_options(kind: KINDS.fetch(option_value(:tag)))
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
        # Reading the visuals evaluates the block, so they are known before the classes are set
        select_options(has_visual: has_visual?, has_visual_item: has_visual?, hover: !option_value(:active) && !option_value(:disabled))

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
          slots_and_content(leading_visuals, text_or_content(@text), trailing_visuals, append_content: false)
        end
      end
    end
  end
end
