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

      # Base's xs, sm, lg and xl sizes, and md as in Flowbite
      variant :size, default: :md, values: {
        xs: { root: "h-8 px-3 py-2 text-xs font-medium", visual: "h-4 w-auto" },
        sm: { root: "h-9 px-3 py-2 text-sm font-medium", visual: "h-5 w-auto" },
        md: { root: "px-4 py-2 text-sm font-medium", visual: "h-5 w-auto" },
        lg: { root: "h-12 px-5 py-3 text-base font-medium", visual: "h-6 w-auto" },
        xl: { root: "h-13 px-6 py-3.5 text-base font-medium", visual: "h-7 w-auto" }
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
