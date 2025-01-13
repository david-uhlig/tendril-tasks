# frozen_string_literal: true

module TendrilTasks
  # Renders a grid of buttons.
  #
  # The buttons stack vertically on mobile viewports and horizontally on
  # larger viewports.
  class ButtonGrid < TendrilTasks::Component
    style :base, "gap-2 grid text-center"

    # Determines the orientation of the button grid
    #
    # Options
    # `:responsive` - Vertical by default (smallest viewports). Horizontal on `sm`
    # and larger viewports
    # `:vertical` - Vertical. Buttons stacked one over another
    # `:horizontal` - Horizontal. Buttons stacked next to each other.
    DEFAULT_ORIENTATION = :responsive
    ORIENTATION_OPTIONS = [ :responsive, :vertical, :horizontal ].freeze

    style :grid_orientation,
          default: DEFAULT_ORIENTATION,
          states: {
            responsive: "grid-cols-1",
            vertical: "grid-cols-1",
            horizontal: ""
          }

    renders_many :buttons, ->(**options) {
      options = parse_button_options(options)
      Gustwave::Button.new(**options)
    }
    alias button with_button

    # Initializes the ButtonGrid.
    #
    # @param orientation [Symbol] Grid behaviour. One of: :responsive, :horizontal, :vertical.
    # @param grid_options [Hash] Options for customizing the grid container.
    # @param options [Hash] General options applied to all buttons.
    def initialize(orientation: DEFAULT_ORIENTATION, grid_options: {}, **options)
      @orientation = fetch_or_fallback(ORIENTATION_OPTIONS, orientation, DEFAULT_ORIENTATION)
      @grid_options = parse_grid_options(grid_options)
      @general_button_options = options.deep_symbolize_keys
    end

    # Renders the component.
    # Wraps the buttons in a grid container if any buttons are defined.
    #
    # @return [String, nil] The HTML structure of the grid or nil if no buttons exist.
    def call
      return unless buttons?

      @grid_options[:class] = styles(
        custom_horizontal: horizontal_cols,
        custom_responsive: responsive_cols,
        custom_grid_options: @grid_options.delete(:class)
      )

      content_tag :div, @grid_options do
        buttons.each do |button|
          concat button
        end
        concat content
      end
    end

    private

    def responsive?
      @orientation == :responsive
    end

    def horizontal?
      @orientation == :horizontal
    end

    def parse_grid_options(options)
      options.deep_symbolize_keys!
      options[:class] = styles(
        base: true,
        grid_orientation: @orientation,
        custom: options.delete(:class)
      )
      options
    end

    def parse_button_options(options)
      options.deep_symbolize_keys!
      options = @general_button_options.merge(options)
      options
    end

    # Returns the responsive tailwind class so that all buttons fit on one
    # horizontal grid row (up to 4)
    def responsive_cols
      return nil unless responsive? && button_count > 1
      return "sm:grid-cols-4" if button_count >= 4

      # List of possible outcomes, so Tailwind picks them up:
      # sm:grid-cols-1 sm:grid-cols-2 sm:grid-cols-3
      "sm:grid-cols-#{button_count}"
    end

    # Returns the responsive tailwind class so that all buttons fit on one
    # horizontal grid row (up to 8)
    def horizontal_cols
      return nil unless horizontal?
      return "grid-cols-8" if button_count >= 8

      # List of possible outcomes, so Tailwind picks them up:
      # grid-cols-1 grid-cols-2 grid-cols-3 grid-cols-4 grid-cols-5 grid-cols-6
      # grid-cols-7
      "grid-cols-#{button_count}"
    end

    def button_count
      @button_count ||= buttons.size
    end
  end
end
