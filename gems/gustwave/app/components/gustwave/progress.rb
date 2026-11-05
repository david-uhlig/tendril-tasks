# frozen_string_literal: true

module Gustwave
  # Use Progress to show how far along a task is, as in Flowbite's progress
  # bar. The track is the root element, and its bar fills to +value+ percent.
  # The track is a +progressbar+ for screen readers, with its value and range.
  # Label it with +aria: { label: "..." }+, or with the outside label below.
  #
  # === Basic Usage
  #
  #   <%= render Gustwave::Progress.new(45, aria: { label: "Upload progress" }) %>
  #
  # === Labels
  #
  # With +label: :inside+, the bar shows the percentage. With +label: :outside+,
  # a row above the track shows the percentage at its end, and the block
  # content as the title at its start. The title labels the track for screen
  # readers. Without block content, the row shows only the percentage.
  #
  #   <%= render Gustwave::Progress.new(45, label: :outside) do %>
  #     Flowbite
  #   <% end %>
  #
  # === Colors and sizes
  #
  #   <%= render Gustwave::Progress.new(85, color: :red, size: :lg) %>
  #
  # Pass +class+ to the track through +options+, and +bar_options+ to the bar,
  # e.g. to color the bar with a shade the colors don't offer:
  #
  #   <%= render Gustwave::Progress.new(85, bar_options: { class: "bg-orange-500" }) %>
  #
  # @param value [Numeric] the percentage complete, from 0 to 100. Values outside that range are clamped.
  # @param size [Symbol] +:sm+, +:md+ (default), +:lg+ or +:xl+ for the height of the track and bar. Ignored with +label: :inside+, whose bar is as tall as its text.
  # @param color [Symbol] +:blue+ (default), +:dark+, +:red+, +:green+, +:yellow+, +:indigo+ or +:purple+ for the bar.
  # @param label [Symbol] +:none+ (default), +:inside+ or +:outside+. Where the percentage is shown.
  # @param bar_options [Hash] HTML attributes for the bar, e.g. +class+. Its classes merge with the bar's own, and win conflicts.
  # @param options [Hash] HTML attributes for the track, e.g. +aria+ or +class+. With +label: :outside+, the track sits in a wrapping +div+ that takes none of them.
  #
  # @status alpha
  class Progress < Gustwave::Component
    base "w-full bg-gray-200 rounded-full dark:bg-gray-700"

    part :bar, "rounded-full"
    part :label_row, "flex justify-between mb-1"
    part :title, "text-base font-medium text-blue-700 dark:text-white"
    part :value_label, "ms-auto text-sm font-medium text-blue-700 dark:text-white"

    variant :size, default: :md, values: {
      sm: { root: "h-1.5", bar: "h-1.5" },
      md: { root: "h-2.5", bar: "h-2.5" },
      lg: { root: "h-4", bar: "h-4" },
      xl: { root: "h-6", bar: "h-6" }
    }, unless: { label: :inside }

    variant :color, part: :bar, default: :blue, values: {
      blue: "bg-blue-600 dark:bg-blue-500",
      dark: "bg-gray-600 dark:bg-gray-300",
      red: "bg-red-600 dark:bg-red-500",
      green: "bg-green-600 dark:bg-green-500",
      yellow: "bg-yellow-400",
      indigo: "bg-indigo-600 dark:bg-indigo-500",
      purple: "bg-purple-600 dark:bg-purple-500"
    }

    variant :label, default: :none, values: {
      none: {},
      inside: { bar: "text-xs font-medium text-blue-100 text-center p-0.5 leading-none" },
      outside: {}
    }

    # @see Gustwave::Progress for the parameters.
    def initialize(value = 0, size: DEFAULT, color: DEFAULT, label: DEFAULT, bar_options: {}, **options)
      @value = value.clamp(0, 100)
      select_options(size:, color:, label:)
      @bar_options = bar_options
      @options = options
    end

    def before_render
      return unless outside?

      # The block is the title. It's read here, so the track can point at it.
      @title = content.presence
      @title_id = generate_random_id(prefix: "progress-title") if @title
    end

    def call
      return track unless outside?

      tag.div do
        safe_join([ label_row, track ])
      end
    end

    private

    def outside?
      option_value(:label) == :outside
    end

    def inside?
      option_value(:label) == :inside
    end

    def percentage
      number_to_percentage(@value, precision: 0)
    end

    def label_row
      tag.div(class: classes(:label_row)) do
        safe_join([ title, tag.span(percentage, class: classes(:value_label)) ].compact)
      end
    end

    def title
      tag.span(@title, id: @title_id, class: classes(:title)) if @title
    end

    def track
      aria = { valuenow: @value, valuemin: 0, valuemax: 100 }
      aria[:labelledby] = @title_id if @title_id
      attributes = configure_html_attributes(@options, role: "progressbar", aria:)

      tag.div(**attributes_for(attributes)) { bar }
    end

    def bar
      attributes = configure_html_attributes(@bar_options, class: classes(:bar), style: "width: #{@value}%")

      tag.div(**attributes) { percentage if inside? }
    end
  end
end
