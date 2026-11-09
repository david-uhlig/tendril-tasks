# frozen_string_literal: true

module Gustwave
  # Use Rating to show a score as a row of stars, as in Flowbite's rating component.
  #
  # The score fills the stars up to its whole part, so 4.95 shows four filled
  # stars and one empty star, as in Flowbite. The stars are the solid star icon,
  # the filled ones in yellow and the empty ones in gray. The row's label is
  # read out by screen readers. Content passed as a block follows the stars in
  # the same row, e.g. the score as text or a review count.
  #
  # Examples:
  #
  # Renders four filled stars of five:
  #
  #   <%= render Gustwave::Rating.new(4) %>
  #
  # Renders the score as text after the stars, with the block:
  #
  #   <%= render Gustwave::Rating.new(4.95) do %>
  #     <%= render Gustwave::Paragraph.new("4.95", class: "ms-2 text-sm font-medium text-gray-500 dark:text-gray-400") %>
  #   <% end %>
  #
  # Renders a single star, with a label that matches the score:
  #
  #   <%= render Gustwave::Rating.new(4.95, max: 1, label: "Rated 4.95 out of 5") %>
  #
  # Renders a larger row of stars with +size+:
  #
  #   <%= render Gustwave::Rating.new(4, size: :lg) %>
  #
  # Changes the color of the empty stars with +empty_star_options+:
  #
  #   <%= render Gustwave::Rating.new(4, empty_star_options: { class: "text-gray-200 dark:text-gray-600" }) %>
  #
  # Spacing around the row is up to the caller, e.g. +class: "mb-4"+.
  #
  # @status alpha
  class Rating < Gustwave::Component
    base "flex items-center"

    part :stars, "flex items-center"
    part :filled_star, "text-yellow-300"
    part :empty_star, "text-gray-300 dark:text-gray-500"

    # The stars' size and the gap between them, matching Flowbite's w-4, w-6
    # and w-8 stars with ms-1, ms-2 and ms-3. Flowbite's star fills its 22x20
    # viewBox; the solid star icon spans 20x19 of a 24x24 viewBox, so it needs
    # a larger box to look as large, and its 2px side padding already adds to
    # the gap. E.g. sm: a 15px star with 5px gaps against Flowbite's 14.5px
    # and 5.5px.
    variant :size, default: :sm, values: {
      sm: { stars: "gap-0.5", filled_star: "size-4.5", empty_star: "size-4.5" },
      md: { stars: "gap-1.5", filled_star: "size-6.5", empty_star: "size-6.5" },
      lg: { stars: "gap-2", filled_star: "size-9", empty_star: "size-9" }
    }

    # @param value [Numeric] the score, e.g. 4.95. Its whole part sets the number of filled stars, clamped to +max+.
    # @param max [Integer] the number of stars. Defaults to 5. Must be a positive Integer.
    # @param size [Symbol] the size of the stars, +:sm+ (default), +:md+ or +:lg+, Flowbite's star sizes.
    # @param label [String, nil] what screen readers announce for the stars. Defaults to a translated "Rated %{value} out of %{max}".
    # @param stars_options [Hash] additional HTML attributes for the wrapper of the stars, e.g. +class+.
    # @param filled_star_options [Hash] additional HTML attributes and component options for each filled star's Gustwave::Icon, e.g. +class+.
    # @param empty_star_options [Hash] additional HTML attributes and component options for each empty star's Gustwave::Icon, e.g. +class+.
    # @param options [Hash] additional HTML attributes for the root element.
    #
    # @raise [ArgumentError] when +max+ isn't a positive Integer.
    #
    # @see Gustwave::Icon
    def initialize(value, max: 5, size: DEFAULT, label: nil,
                   stars_options: {}, filled_star_options: {}, empty_star_options: {}, **options)
      raise ArgumentError, "max must be a positive Integer, got #{max.inspect}" unless max.is_a?(Integer) && max.positive?

      @value = value
      @max = max
      @label = label
      @filled = value.floor.clamp(0, max)
      @stars_options = stars_options
      @filled_star_options = filled_star_options
      @empty_star_options = empty_star_options
      select_options(size:)
      @options = options
    end

    def before_render
      label = @label || t(".label", value: helpers.number_with_precision(@value, precision: 2, strip_insignificant_zeros: true), max: @max)
      @config = attributes_for(@options)
      @stars_config = configure_html_attributes(attributes_for(:stars, @stars_options), role: "img", aria: { label: })
    end

    def call
      content_tag :div, **@config do
        safe_join([ stars, content.presence ].compact)
      end
    end

    private
    attr_reader :config, :stars_config

    def stars
      content_tag :div, **stars_config do
        safe_join(Array.new(@max) { |index| star_icon(index < @filled ? :filled_star : :empty_star) })
      end
    end

    def star_icon(part)
      options = part == :filled_star ? @filled_star_options : @empty_star_options
      render Gustwave::Icon.new(:star, theme: :solid, **attributes_for(part, options))
    end
  end
end
