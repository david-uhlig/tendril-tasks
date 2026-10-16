# frozen_string_literal: true

module Gustwave
  module Buttons
    class GradientDuotoneOutline < Gustwave::Buttons::Base
      # The root element is the gradient border; the inner span holds the
      # label and visuals, so it takes the size styles.
      base "relative inline-flex items-center justify-center p-0.5 text-gray-900 group bg-linear-to-br dark:text-white"

      variant :scheme, default: :purple_to_blue, values: {
        base: "",
        purple_to_blue: "from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white focus:ring-blue-300 dark:focus:ring-blue-800",
        cyan_to_blue: "from-cyan-500 to-blue-500 group-hover:from-cyan-500 group-hover:to-blue-500 hover:text-white focus:ring-cyan-200 dark:focus:ring-cyan-800",
        green_to_blue: "from-green-400 to-blue-600 group-hover:from-green-400 group-hover:to-blue-600 hover:text-white focus:ring-green-200 dark:focus:ring-green-800",
        purple_to_pink: "from-purple-500 to-pink-500 group-hover:from-purple-500 group-hover:to-pink-500 hover:text-white focus:ring-purple-200 dark:focus:ring-purple-800",
        pink_to_orange: "from-pink-500 to-orange-400 group-hover:from-pink-500 group-hover:to-orange-400 hover:text-white focus:ring-pink-200 dark:focus:ring-pink-800",
        teal_to_lime: "from-teal-300 to-lime-300 group-hover:from-teal-300 group-hover:to-lime-300 dark:hover:text-gray-900 focus:ring-lime-200 dark:focus:ring-lime-800",
        red_to_yellow: "from-red-200 via-red-300 to-yellow-200 group-hover:from-red-200 group-hover:via-red-300 group-hover:to-yellow-200 dark:hover:text-gray-900 focus:ring-red-100 dark:focus:ring-red-400"
      }

      # Declared again after the inner part, so the size styles win its
      # conflicts and the visual-only padding wins theirs. Changes to these on
      # Buttons::Base don't reach this theme; extend it separately, e.g.
      #
      #   extend_variant :size, values: { "2xl": { inner: "…", visual: "…" } }
      #   extend_toggle :visual_only, part: :inner, values: { "2xl": "…" }
      remove_variant :size
      remove_toggle :has_visual
      remove_toggle :visual_only

      part :inner,
           "relative px-5 py-2.5 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-transparent dark:group-hover:bg-transparent gap-1.5"

      variant :size, default: :md, values: {
        xs: { inner: "px-2.5 py-2 text-xs font-medium", visual: "h-4 w-auto" },
        sm: { inner: "px-3 py-2 text-sm font-medium", visual: "h-5 w-auto" },
        md: { inner: "px-5 py-2.5 text-sm font-medium", visual: "h-5 w-auto" },
        lg: { inner: "px-5 py-3 text-base font-medium", visual: "h-6 w-auto" },
        xl: { inner: "px-6 py-3.5 text-base font-medium", visual: "h-7 w-auto" }
      }

      toggle :has_visual, "inline-flex items-center align-bottom gap-1.5", part: :inner

      toggle :visual_only, per: :size, part: :inner, values: {
        xs: "p-2",
        sm: "p-2",
        md: "p-2.5",
        lg: "p-3",
        xl: "p-3.5"
      }

      def initialize(text = nil, scheme: DEFAULT, size: DEFAULT, **options)
        @text = text
        @options = options
        select_options(scheme:, size:)
        @scheme = option_value(:scheme)
      end

      def before_render
        select_options(has_visual: has_visual?, visual_only: !has_content?)
        @config = attributes_for(@options)
        @inner_config = { class: classes(:inner) }
      end

      def call
        render base_button do
          tag.span **@inner_config do
            slots_and_content(leading_visuals, text_or_content, trailing_visuals, append_content: false)
          end
        end
      end

      private

      def base_button
        @base_button ||= Gustwave::Buttons::Base.new(scheme: :base, **@config)
      end
    end
  end
end
