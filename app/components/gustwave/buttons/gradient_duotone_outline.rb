# frozen_string_literal: true

module Gustwave
  module Buttons
    class GradientDuotoneOutline < Gustwave::Buttons::Base
      theme_for Gustwave::Button

      style :base,
            "relative inline-flex items-center justify-center p-0.5 text-gray-900 group bg-gradient-to-br dark:text-white"

      style :scheme,
            default: :purple_to_blue,
            strategy: :replace,
            states: {
              none: "",
              base: "",
              purple_to_blue: "from-purple-600 to-blue-500 group-hover:from-purple-600 group-hover:to-blue-500 hover:text-white focus:ring-blue-300 dark:focus:ring-blue-800",
              cyan_to_blue: "from-cyan-500 to-blue-500 group-hover:from-cyan-500 group-hover:to-blue-500 hover:text-white focus:ring-cyan-200 dark:focus:ring-cyan-800",
              green_to_blue: "from-green-400 to-blue-600 group-hover:from-green-400 group-hover:to-blue-600 hover:text-white focus:ring-green-200 dark:focus:ring-green-800",
              purple_to_pink: "from-purple-500 to-pink-500 group-hover:from-purple-500 group-hover:to-pink-500 hover:text-white focus:ring-purple-200 dark:focus:ring-purple-800",
              pink_to_orange: "from-pink-500 to-orange-400 group-hover:from-pink-500 group-hover:to-orange-400 hover:text-white focus:ring-pink-200 dark:focus:ring-pink-800",
              teal_to_lime: "from-teal-300 to-lime-300 group-hover:from-teal-300 group-hover:to-lime-300 dark:hover:text-gray-900 focus:ring-lime-200 dark:focus:ring-lime-800",
              red_to_yellow: "from-red-200 via-red-300 to-yellow-200 group-hover:from-red-200 group-hover:via-red-300 group-hover:to-yellow-200 dark:hover:text-gray-900 focus:ring-red-100 dark:focus:ring-red-400"
            }

      style :base_inner,
            "relative px-5 py-2.5 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0 gap-1.5"

      style :size_inner,
            default: :md,
            states: {
              none: "",
              xs: "px-2.5 py-2 text-xs font-medium",
              sm: "px-3 py-2 text-sm font-medium",
              md: "px-5 py-2.5 text-sm font-medium",
              lg: "px-5 py-3 text-base font-medium",
              xl: "px-6 py-3.5 text-base font-medium"
            }

      def initialize(text = nil,
                     scheme: default_layer_state(:scheme),
                     size: default_layer_state(:size),
                     **options)
        @text = text
        @size = size
        @scheme = scheme
        @options = options
        @kwargs = { scheme:, size: }
      end

      def before_render
        @config = configure_html_attributes(
          @options,
          class: styles(
            base: render_base_styles?,
            scheme:
          )
        )

        @inner_config = {
          class: styles(
            base_inner: true,
            size_inner: @size,
            has_visual: has_visual?,
            size_overwrite_if_visual_only: (@size unless has_content?)
          )
        }
      end

      def call
        render base_button do
          tag.span **@inner_config do
            slots_and_content(leading_visual, text_or_content, trailing_visual, append_content: false)
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
