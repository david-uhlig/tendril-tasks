# frozen_string_literal: true

module Gustwave
  # Use DismissButton to render a button that dismisses the target element.
  #
  # The button is styled as a close button with an "X" icon. It closes the
  # element with the HTML id attribute that matches the target parameter. The
  # target element doesn't require any additional markup.
  #
  # @example
  #   render Gustwave::DismissButton.new("my-modal", size: :lg)
  #
  # TODO add scheme support so we can dismiss colored badges
  class DismissButton < Gustwave::Component
    style :base,
          "ms-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex items-center justify-center dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"

    style :size,
          default: :md,
          states: {
            xs: "h-4 w-4",
            sm: "h-5 w-5",
            md: "h-6 w-6",
            lg: "h-8 w-8",
            xl: "h-10 w-10"
          }

    # @param target [String] the target selector to dismiss
    # @param size [Symbol] the size of the button. One of :xs, :sm, :md, :lg, :xl.
    # @param label [String] the aria label for the button
    # @param options [Hash] optional HTML options for the button
    def initialize(target,
                   size: default_layer_state(:size),
                   label: nil,
                   **options)
      @target = target
      @label = label

      options.deep_symbolize_keys!

      layers = {}
      layers[:base] = :on
      layers[:size] = size
      layers[:custom] = options.delete(:class)

      options[:class] = styles(**layers)
      @options = options
    end

    def before_render
      @label ||= t(".close")
    end

    def call
      render Gustwave::Button.new(scheme: :none,
                                  data: { dismiss_target: "##{target}" },
                                  aria: { label: label },
                                  **options) do
        safe_join([ screenreader_label, close_icon ])
      end
    end

    private
    attr_reader :options, :target, :label

    def screenreader_label
      tag.span label, class: "sr-only"
    end

    def close_icon
      render Gustwave::Icon.new(:close,
                         position: :standalone,
                         size: :md)
    end
  end
end
