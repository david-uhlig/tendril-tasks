# frozen_string_literal: true

# Renders a grid of buttons.
#
# The buttons stack vertically on mobile viewports and horizontally on
# larger viewports.
class ButtonGridComponent < ApplicationComponent
  # Default CSS classes applied to the grid container.
  DEFAULT_GRID_CLASS = "gap-2 grid grid-cols-1"

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

    @grid_options[:class] << responsive_cols

    content_tag :div, @grid_options do
      buttons.each do |button|
        concat button
      end
    end
  end

  private

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

  # Returns the responsive tailwind class so that all buttons fit on one
  # horizontal grid row (up to 6)
  #
  # Bear with me before submitting this to The Daily WTF. Somehow string
  # interpolation doesn't work for dynamically generated classes in this
  # component. Although the class name would appear correctly in the
  # HTML-document, it has no effect whatsoever. So, this workaround is the only
  # option for now.
  def responsive_cols
    case buttons.count
    when 1
      ""
    when 2
      " sm:grid-cols-2"
    when 3
      " sm:grid-cols-3"
    when 4
      " sm:grid-cols-4"
    when 5
      " sm:grid-cols-5"
    when 6
      " sm:grid-cols-6"
    else
      " sm:grid-cols-2"
    end
  end
end
