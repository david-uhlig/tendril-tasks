# frozen_string_literal: true

# Renders a grid of buttons.
#
# The buttons stack vertically on mobile viewports and horizontally on
# larger viewports.
class ButtonGridComponent < ApplicationComponent
  # Default CSS classes applied to the grid container.
  DEFAULT_GRID_CLASS = "grid grid-cols-1 gap-2"

  renders_many :buttons, ->(**options) {
    options = parse_button_options(options)
    ::ButtonComponent.new(**options)
  }
  alias button with_button

  # Initializes the ButtonGridComponent.
  #
  # @param grid_options [Hash] Options for customizing the grid container.
  # @param options [Hash] General options applied to all buttons.
  def initialize(grid_options: {}, **options)
    @grid_options = parse_grid_options(grid_options)
    @general_button_options = options.stringify_keys
  end

  # Renders the component.
  # Wraps the buttons in a grid container if any buttons are defined.
  #
  # @return [String, nil] The HTML structure of the grid or nil if no buttons exist.
  def call
    return unless buttons?

    tag.div **@grid_options do
      buttons.each do |button|
        concat button
      end
    end
  end

  private

  # Prepares adjustments to the grid options before rendering.
  # Adds a responsive grid column class based on the number of buttons.
  def before_render
    @grid_options[:class] += " sm:grid-cols-#{buttons.size}"
  end

  def parse_grid_options(options)
    options.stringify_keys!
    options["class"] = class_names(DEFAULT_GRID_CLASS, options.delete("class"))
    options.symbolize_keys!
    options
  end

  def parse_button_options(options)
    options.stringify_keys!
    options = @general_button_options.merge(options)
    options.symbolize_keys!
    options
  end
end
