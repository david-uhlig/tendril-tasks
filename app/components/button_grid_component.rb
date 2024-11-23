# frozen_string_literal: true

# Renders a grid of buttons.
#
# The buttons stack vertically on mobile viewports and horizontally on
# larger viewports.
class ButtonGridComponent < ApplicationComponent
  GRID_DEFAULT_CLASS = "gap-2 grid text-center"

  # Determines the orientation of the button grid
  #
  # Options
  # `:responsive` - Vertical by default (smallest viewports). Horizontal on `sm`
  # and larger viewports
  # `:vertical` - Vertical. Buttons stacked one over another
  # `:horizontal` - Horizontal. Buttons stacked next to each other.
  DEFAULT_ORIENTATION = :responsive
  ORIENTATION_OPTIONS = [ DEFAULT_ORIENTATION, :vertical, :horizontal ].freeze

  GRID_ORIENTATION_MAPPINGS = {
    responsive: "grid-cols-1",
    vertical: "grid-cols-1",
    horizontal: "grid-rows-1"
  }

  renders_many :buttons, ->(**options) {
    options = parse_button_options(options)
    ::ButtonComponent.new(**options)
  }
  alias button with_button

  # Initializes the ButtonGridComponent.
  #
  # @param orientation [Symbol] Grid behaviour. One of: :responsive, :horizontal, :vertical.
  # @param grid_options [Hash] Options for customizing the grid container.
  # @param options [Hash] General options applied to all buttons.
  def initialize(orientation: DEFAULT_ORIENTATION, grid_options: {}, **options)
    @orientation = fetch_or_fallback(ORIENTATION_OPTIONS, orientation, DEFAULT_ORIENTATION)
    @grid_options = parse_grid_options(grid_options)
    @general_button_options = options.stringify_keys
  end

  # Renders the component.
  # Wraps the buttons in a grid container if any buttons are defined.
  #
  # @return [String, nil] The HTML structure of the grid or nil if no buttons exist.
  def call
    return unless buttons?

    @grid_options[:class] << responsive_cols

    content_tag :div, @grid_options do
      buttons.each do |button|
        concat button
      end
    end
  end

  private

  def responsive?
    @orientation == :responsive
  end

  def parse_grid_options(options)
    options.stringify_keys!
    options["class"] = class_names(
      GRID_DEFAULT_CLASS,
      GRID_ORIENTATION_MAPPINGS[@orientation],
      options.delete("class")
    )
    options.symbolize_keys!
    options
  end

  def parse_button_options(options)
    options.stringify_keys!
    options = @general_button_options.merge(options)
    options.symbolize_keys!
    options
  end

  # Returns the responsive tailwind class so that all buttons fit on one
  # horizontal grid row (up to 4)
  #
  # Bear with me before submitting this to The Daily WTF. Somehow string
  # interpolation doesn't work for dynamically generated classes in this
  # component. Although the class name would appear correctly in the
  # HTML-document, it has no effect whatsoever. So, this workaround is the only
  # option for now.
  def responsive_cols
    return "" unless responsive? && buttons.size > 1

    case buttons.size
    when 2
      " sm:grid-cols-2"
    when 3
      " sm:grid-cols-3"
    else
      " sm:grid-cols-4"
    end
  end
end
