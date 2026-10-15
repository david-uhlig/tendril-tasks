# frozen_string_literal: true

module Gustwave
  module Buttons
    # A transparent, compact button that sits inside other elements, e.g. the
    # dismiss button of a +Gustwave::Badge+. Its colors are meant for the
    # matching light backgrounds of badges and alerts.
    class Inline < Gustwave::Buttons::Base
      base "inline-flex items-center justify-center rounded-xs bg-transparent focus:outline-hidden focus:ring-2 disabled:cursor-not-allowed",
           unless: { scheme: :none }

      extend_variant :scheme, default: :blue, values: {
        blue: "text-blue-400 hover:bg-blue-200 hover:text-blue-900 focus:ring-blue-300 dark:hover:bg-blue-800 dark:hover:text-blue-300",
        dark: "text-gray-400 hover:bg-gray-200 hover:text-gray-900 focus:ring-gray-300 dark:hover:bg-gray-600 dark:hover:text-gray-300",
        red: "text-red-400 hover:bg-red-200 hover:text-red-900 focus:ring-red-300 dark:hover:bg-red-800 dark:hover:text-red-300",
        green: "text-green-400 hover:bg-green-200 hover:text-green-900 focus:ring-green-300 dark:hover:bg-green-800 dark:hover:text-green-300",
        yellow: "text-yellow-400 hover:bg-yellow-200 hover:text-yellow-900 focus:ring-yellow-300 dark:hover:bg-yellow-800 dark:hover:text-yellow-300",
        indigo: "text-indigo-400 hover:bg-indigo-200 hover:text-indigo-900 focus:ring-indigo-300 dark:hover:bg-indigo-800 dark:hover:text-indigo-300",
        purple: "text-purple-400 hover:bg-purple-200 hover:text-purple-900 focus:ring-purple-300 dark:hover:bg-purple-800 dark:hover:text-purple-300",
        pink: "text-pink-400 hover:bg-pink-200 hover:text-pink-900 focus:ring-pink-300 dark:hover:bg-pink-800 dark:hover:text-pink-300"
      }

      # Keeps the visual sizes of Base from :xs up.
      extend_variant :size, default: :xs, values: {
        "3xs": { root: "p-0.5 text-xs", visual: "h-3 w-auto" },
        "2xs": { root: "p-1 text-xs", visual: "h-3.5 w-auto" },
        xs: "p-1 text-xs",
        sm: "p-1.5 text-sm",
        md: "p-1.5 text-sm",
        lg: "p-2 text-base",
        xl: "p-2 text-base"
      }

      # Indicators scale with the text below :xs
      extend_derived :indicator_size, values: { "3xs": :auto, "2xs": :auto }

      # Inline buttons are already compact, with or without text
      extend_toggle :visual_only, values: {
        "3xs": "",
        "2xs": "",
        xs: "",
        sm: "",
        md: "",
        lg: "",
        xl: ""
      }
    end
  end
end
