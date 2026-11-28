# frozen_string_literal: true

module Gustwave
  class List < Gustwave::Component
    # One item of a Gustwave::List, set with +with_item+. Renders only inside a
    # Gustwave::List; the list sets its orientation and, in a divided list, its position.
    #
    # Renders leading visuals, see Gustwave::Visuals, e.g. an icon before the
    # text. Visuals are decorative and hidden from screen readers.
    #
    # @status alpha
    class Item < Gustwave::Component
      include Gustwave::Visuals
      renders_visuals :leading_visuals

      # Gustwave's icons leave 3 units of their 24x24 viewBox empty on each side.
      # At size-4.5 the glyph is about as large as Flowbite's w-3.5 icon, and the
      # negative margin makes up for the empty part, so the icon takes Flowbite's
      # 14px and gap-2 leaves its 8px between icon and text.
      part :visual, "size-4.5 -m-0.5 shrink-0"

      # Set by Gustwave::List
      variant :orientation, default: :vertical, allow_none: false, internal: true, values: {
        vertical: "",
        horizontal: "me-4 md:me-6"
      }

      # Set by a divided Gustwave::List
      variant :list_position, default: :none, internal: true, values: {
        only: "",
        first: "pb-3 sm:pb-4",
        middle: "py-3 sm:py-4",
        last: "pt-3 sm:pt-4"
      }

      # Selected by the item when it has a visual; declared after Visuals' has_visual so flex wins over inline-flex
      toggle :has_visual_item, "flex items-center gap-2", internal: true

      # @param text [String, nil] The item text. Takes precedence over block content.
      # @param icon [Symbol, nil] Shorthand for +with_leading_visual_icon+: an outline icon shown before the text.
      # @param options [Hash] HTML attributes for the +li+ element.
      def initialize(text = nil, icon: nil, **options)
        @text = text
        with_leading_visual_icon(icon) if icon
        @options = options
      end

      # Called by Gustwave::List. Each keyword is optional.
      #
      # @param orientation [Symbol, nil] +:vertical+ or +:horizontal+.
      # @param list_position [Symbol, nil] +:only+, +:first+, +:middle+ or +:last+ in a divided list, or +nil+ in a list that isn't divided.
      # @return [void]
      def apply_slot_context(orientation: nil, list_position: nil, **)
        select_options(orientation:) if orientation
        select_options(list_position:) if list_position
      end

      def before_render
        select_options(has_visual: has_visual?, has_visual_item: has_visual?)
        @config = attributes_for(@options)
      end

      def call
        tag.li(**@config) { slots_and_content(leading_visuals, text_or_content(@text), append_content: false) }
      end
    end
  end
end
