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
      SCHEME_OPTIONS = layer_states(:scheme).keys

      style :base_inner,
            "relative px-5 py-2.5 transition-all ease-in duration-75 bg-white dark:bg-gray-900 rounded-md group-hover:bg-opacity-0"

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

        options.symbolize_keys!
        layers = {}
        layers[:base] = true unless scheme == :none
        layers[:scheme] = scheme

        options[:class] = styles(**layers)
        @options = options

        layers = {}
        layers[:base_inner] = true
        layers[:size_inner] = @size

        @inner_options = {}
        @inner_options[:class] = styles(**layers)
      end

      def call
        if leading_visual? || trailing_visual?
          @inner_options[:class] = styles(custom: @inner_options.delete(:class),
                                          has_visual: true)
        end

        render base_button do
          tag.span **@inner_options do
            concat(leading_visual) if leading_visual?
            concat @text || content
            concat(trailing_visual) if trailing_visual?
          end
        end
      end

      private

      def base_button
        @base_button ||= Gustwave::Buttons::Base.new(scheme: :base, **@options)
      end
    end
  end
end
