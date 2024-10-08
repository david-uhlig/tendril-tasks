# frozen_string_literal: true

# Use `ButtonComponent` for actions (e.g. in forms). Use links for destinations, or moving from one page to another.
class ButtonComponent < ApplicationComponent
  DEFAULT_SCHEME = :default
  SCHEME_MAPPINGS = {
    DEFAULT_SCHEME => "btn-default",
    :alternative => "btn-alternative",
    :dark => "btn-dark",
    :light => "btn-light",
    :green => "btn-green",
    :red => "btn-red",
    :yellow => "btn-yellow",
    :purple => "btn-purple",
    :duotone_purple_to_blue => "btn-duotone-purple-to-blue"
  }.freeze
  SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

  DEFAULT_SIZE = :base
  SIZE_MAPPINGS = {
    DEFAULT_SIZE => "px-5 py-2.5 text-sm font-medium",
    :extra_small => "px-3 py-2 text-xs font-medium",
    :small => "px-3 py-2 text-sm font-medium",
    :large => "px-5 py-3 text-base font-medium",
    :extra_large => "px-6 py-3.5 text-base font-medium"
  }.freeze
  SIZE_OPTIONS = SIZE_MAPPINGS.keys

  # Renders an image or visual element to appear to the left of the button text.
  # This is typically used for icons or decorative visuals accompanying the button label.
  #
  # @param src [String] The source URL or path to the image file to display.
  # @param alt [String, nil] The alternative text for the image, useful for accessibility.
  #   If not provided, the image will have no `alt` text.
  # @param classes [String] A string of CSS classes for controlling the image size and appearance.
  #   Defaults to "w-5 h-5 me-2", which applies width and height of 5 units and a margin-end of 2 units
  #   (based on Tailwind CSS utility classes).
  #
  # @example Basic usage
  #   render(ButtonComponent.new) do |button|
  #     button.leading_visual src: "icon.svg", alt: "Icon description"
  #     "Submit"
  #   end
  #
  # @example Custom classes
  #   render(ButtonComponent.new) do |button|
  #     button.leading_visual src: "icon.svg", alt: "Icon description", classes: "w-10 h-10 me-4"
  #     "Submit"
  #   end
  #
  # @note The `aria-hidden="true"` attribute is automatically applied to hide the image from screen readers,
  #   as it is usually decorative and doesn't convey critical information.
  #
  renders_one :leading_visual, ->(src:, alt: nil, classes: "w-5 h-5 me-2") do
    image_tag src, alt: alt, class: classes, aria: { hidden: "true" }
  end

  # @param scheme [Symbol] <%= one_of(ButtonComponent::SCHEME_OPTIONS) %>
  # @param size [Symbol] <%= one_of(ButtonComponent::SIZE_OPTIONS) %>
  # @param classes [String, nil] Additional CSS classes that are merged with the classes resulting from the `scheme:` option.
  def initialize(scheme: DEFAULT_SCHEME, size: DEFAULT_SIZE, classes: nil)
    @classes = class_names(
      SCHEME_MAPPINGS[fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)],
      SIZE_MAPPINGS[fetch_or_fallback(SIZE_OPTIONS, size, DEFAULT_SIZE)],
      classes
    )
  end
end
