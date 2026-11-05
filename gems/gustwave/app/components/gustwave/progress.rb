# frozen_string_literal: true

module Gustwave
  # Use Progress to show a completion rate as a bar, as in Flowbite's progress
  # bars. The value is a percentage, clamped to 0..100.
  #
  # Examples:
  #
  # Renders a bar filled to 45%:
  #
  #   <%= render Gustwave::Progress.new(45, aria: { label: "Upload" }) %>
  #
  # Picks a height with +size+:
  #
  #   <%= render Gustwave::Progress.new(45, size: :lg, aria: { label: "Upload" }) %>
  #
  # Renders a label inside the fill from a block. The label sets the bar's
  # height, whatever the +size+:
  #
  #   <%= render Gustwave::Progress.new(45, aria: { label: "Upload" }) do %>45%<% end %>
  #
  # Picks a colour with +color+, or any other colour with +fill_options+. Also
  # set the dark mode colour, and the text colour if the bar has a label inside,
  # because the default colour's stay otherwise:
  #
  #   <%= render Gustwave::Progress.new(45, fill_options: { class: "bg-teal-600 dark:bg-teal-500" }, aria: { label: "Upload" }) %>
  #
  # Puts a label outside the bar by composition:
  #
  #   <div class="flex justify-between mb-1">
  #     <span id="upload-label" class="text-base font-medium text-blue-700 dark:text-white">Flowbite</span>
  #     <span class="text-sm font-medium text-blue-700 dark:text-white">45%</span>
  #   </div>
  #   <%= render Gustwave::Progress.new(45, aria: { labelledby: "upload-label" }) %>
  #
  # Callers must name the bar with +aria-label+ or +aria-labelledby+. The
  # +progressbar+ role makes its children presentational, so a screen reader
  # won't announce the text of a label inside the fill. Pass
  # <tt>aria: { valuetext: "..." }</tt> when the label says more than the
  # percentage.
  #
  # @status alpha
  class Progress < Gustwave::Component
    base "w-full bg-gray-200 rounded-full dark:bg-gray-700"

    part :fill, "rounded-full"

    variant :size, default: :md, values: {
      sm: { root: "h-1.5", fill: "h-1.5" },
      md: { root: "h-2.5", fill: "h-2.5" },
      lg: { root: "h-4", fill: "h-4" },
      xl: { root: "h-6", fill: "h-6" }
    }

    # The text colour only shows on a label inside the fill
    variant :color, part: :fill, default: :blue, values: {
      blue: "bg-blue-600 dark:bg-blue-500 text-blue-100",
      dark: "bg-gray-600 dark:bg-gray-300 text-white dark:text-gray-900",
      red: "bg-red-600 dark:bg-red-500 text-red-100",
      green: "bg-green-600 dark:bg-green-500 text-green-100",
      yellow: "bg-yellow-400 text-yellow-900",
      indigo: "bg-indigo-600 dark:bg-indigo-500 text-indigo-100",
      purple: "bg-purple-600 dark:bg-purple-500 text-purple-100"
    }

    # A label inside the fill sets the height, whatever the size. Declared after
    # the size, so that its h-auto wins the conflict.
    toggle :has_label, {
      root: "h-auto",
      fill: "h-auto p-0.5 text-xs font-medium text-center leading-none"
    }, internal: true

    # @param value [Numeric, nil] The percentage, clamped to 0..100. +nil+ counts as 0.
    # @param color [Symbol] The colour of the fill. Defaults to :blue.
    # @param size [Symbol] The height of the bar. Defaults to :md.
    # @param fill_options [Hash] Additional HTML attributes for the fill, e.g. +class+ for any other colour. Its +style+ is kept, and the width always applies.
    # @param options [Hash] Additional HTML attributes for the root element, e.g. +aria+ or +class+.
    def initialize(value = 0, color: DEFAULT, size: DEFAULT, fill_options: {}, **options)
      select_options(color:, size:)
      @percent = format("%g", value.to_f.clamp(0, 100))
      @fill_options = fill_options
      @options = configure_html_attributes(
        options,
        role: "progressbar",
        aria: { valuenow: @percent, valuemin: 0, valuemax: 100 }
      )
    end

    def before_render
      # Must select here to know whether there is a label
      select_options(has_label: content.present?)
      @config = attributes_for(@options)
      @fill_config = attributes_for(:fill, @fill_options)
      @fill_config[:style] = [ @fill_config[:style], "width: #{@percent}%" ].compact.join("; ")
    end

    def call
      tag.div(**@config) { tag.div(content, **@fill_config) }
    end
  end
end
