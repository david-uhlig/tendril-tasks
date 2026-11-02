# frozen_string_literal: true

module Gustwave
  # Use `Button` for actions (e.g. in forms). Use links for destinations, or moving from one page to another.
  module Buttons
    class Default < Gustwave::Buttons::Base
      extend_variant :color, default: :default, values: {
        default: "text-white bg-blue-700 hover:bg-blue-800 focus:ring-blue-300 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800 disabled:bg-blue-400 disabled:hover:bg-blue-400 dark:disabled:bg-blue-500 dark:disabled:hover:bg-blue-500",
        alternative: "text-gray-900 bg-white border border-gray-200 hover:bg-gray-100 hover:text-blue-700 focus:ring-gray-100 focus:z-10 dark:focus:ring-gray-700 dark:bg-gray-800 dark:text-gray-400 dark:border-gray-600 dark:hover:text-white dark:hover:bg-gray-700",
        dark: "text-white bg-gray-800 hover:bg-gray-900 focus:ring-gray-300 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-700 dark:border-gray-700",
        light: "text-gray-900 bg-white border border-gray-300 hover:bg-gray-100 focus:ring-gray-100 dark:bg-gray-800 dark:text-white dark:border-gray-600 dark:hover:bg-gray-700 dark:hover:border-gray-600 dark:focus:ring-gray-700",
        green: "text-white bg-green-700 hover:bg-green-800 focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800 disabled:bg-green-400 disabled:hover:bg-green-400 dark:disabled:bg-green-500 dark:disabled:hover:bg-green-500",
        red: "text-white bg-red-700 hover:bg-red-800 focus:ring-red-300 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-900 disabled:bg-red-400 disabled:hover:bg-red-400 dark:disabled:bg-red-500 dark:disabled:hover:bg-red-500",
        yellow: "text-white bg-yellow-400 hover:bg-yellow-500 focus:ring-yellow-300 dark:focus:ring-yellow-900",
        purple: "text-white bg-purple-700 hover:bg-purple-800 focus:ring-purple-300 dark:bg-purple-600 dark:hover:bg-purple-700 dark:focus:ring-purple-900 disabled:bg-purple-400 disabled:hover:bg-purple-400 dark:disabled:bg-purple-500 dark:disabled:hover:bg-purple-500"
      }
    end
  end
end
