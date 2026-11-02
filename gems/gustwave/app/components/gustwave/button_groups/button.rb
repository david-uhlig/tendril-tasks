# frozen_string_literal: true

module Gustwave
  module ButtonGroups
    # A button within Gustwave::ButtonGroup. The group selects its position,
    # which sets the border and rounding. +pill+ has no effect in a group.
    class Button < Gustwave::Buttons::Base
      # Replaces Base's rounded-lg focus:ring-4
      base "text-center whitespace-nowrap align-bottom overflow-hidden focus:outline-hidden focus:ring-2 focus:z-10 disabled:cursor-not-allowed"

      extend_variant :color, default: :default, values: {
        default: "text-gray-900 bg-white border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:ring-blue-700 focus:text-blue-700 dark:bg-gray-800 dark:border-gray-700 dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:ring-blue-500 dark:focus:text-white",
        outline: "text-gray-900 bg-transparent border-gray-900 hover:bg-gray-900 hover:text-white focus:ring-gray-500 focus:bg-gray-900 focus:text-white dark:border-white dark:text-white dark:hover:text-white dark:hover:bg-gray-700 dark:focus:bg-gray-700"
      }

      # Flowbite's padding, text and icon space per size, with no fixed height, so
      # the border adds to the height as in Flowbite. The icon boxes are larger than
      # Flowbite's 12px and 16px because Gustwave's icons leave a margin around their
      # drawing, and the negative margin keeps Flowbite's layout.
      variant :size, default: :md, values: {
        xs: { root: "px-3 py-2 text-xs font-medium gap-2", visual: "h-4 w-auto -mx-0.5" },
        sm: { root: "px-3 py-2 text-sm font-medium gap-2", visual: "h-4 w-auto -mx-0.5" },
        md: { root: "px-4 py-2 text-sm font-medium gap-2", visual: "h-4 w-auto -mx-0.5" },
        lg: { root: "px-5 py-3 text-base font-medium gap-2", visual: "h-5 w-auto -mx-0.5" },
        xl: { root: "px-6 py-3.5 text-base font-medium gap-2", visual: "h-5 w-auto -mx-0.5" }
      }

      # Selected by Gustwave::ButtonGroup. Declared after color so it wins.
      variant :group_position, default: :only, internal: true, values: {
        only: "rounded-lg border",
        first: "rounded-none rounded-s-lg border",
        middle: "rounded-none border-0 border-y",
        last: "rounded-none rounded-e-lg border"
      }

      # Called by Gustwave::ButtonGroup before rendering
      def apply_slot_context(group_position:, **)
        select_options(group_position:)
      end
    end
  end
end
