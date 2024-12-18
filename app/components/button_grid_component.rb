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
    horizontal: ""
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
    @general_button_options = options.deep_symbolize_keys
  end

  # Renders the component.
  # Wraps the buttons in a grid container if any buttons are defined.
  #
  # @return [String, nil] The HTML structure of the grid or nil if no buttons exist.
  def call
    return unless buttons?

    @grid_options[:class] << horizontal_cols
    @grid_options[:class] << responsive_cols

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
    options[:class] = class_names(
      GRID_DEFAULT_CLASS,
      GRID_ORIENTATION_MAPPINGS[@orientation],
      options.delete(:class)
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

  # Returns the responsive tailwind class so that all buttons fit on one
  # horizontal grid row (up to 8)
  #
  # See above for reasoning why it is implemented this way.
  def horizontal_cols
    return "" unless horizontal?

    case buttons.size
    when 1
      " grid-cols-1"
    when 2
      " grid-cols-2"
    when 3
      " grid-cols-3"
    when 4
      " grid-cols-4"
    when 5
      " grid-cols-5"
    when 6
      " grid-cols-6"
    when 7
      " grid-cols-7"
    else
      " grid-cols-8"
    end
  end
end
