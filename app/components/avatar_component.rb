# frozen_string_literal: true

# Renders an avatar image with configurable styling options for shape and size.
#
# @!attribute [r] DEFAULT_SCHEME
#   @return [Symbol] The default shape scheme for the avatar.
#
# @!attribute [r] SCHEME_MAPPINGS
#   @return [Hash{Symbol => String}] The hash that maps shape schemes to CSS classes.
#
# @!attribute [r] DEFAULT_SIZE
#   @return [Symbol] The default size for the avatar.
#
# @!attribute [r] SIZE_MAPPINGS
#   @return [Hash{Symbol => String}] The hash that maps size options to width/height CSS classes.
#
# @param src [String] the source URL of the avatar image.
# @param alt [String, nil] the alt text for the image (optional).
# @param scheme [Symbol] the shape scheme for the avatar (default: :round).
# @param size [Symbol] the size of the avatar (default: :medium).
# @param classes [String, nil] additional custom CSS classes (optional).
# @return [void]
#
# == Example Usage:
#   <%= render AvatarComponent.new(src: "https://example.com/avatar.jpg", alt: "User's avatar", scheme: :square, size: :large) %>
#
class AvatarComponent < ApplicationComponent
  DEFAULT_SCHEME = :round
  SCHEME_MAPPINGS = {
    round: "rounded-full",
    square: "rounded"
  }.freeze
  SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

  DEFAULT_SIZE = :medium
  SIZE_MAPPINGS = {
    extra_small: "w-6 h-6",
    small: "w-8 h-8",
    medium: "w-10 h-10",
    large: "w-20 h-20",
    extra_large: "w-36 h-36"
  }.freeze
  SIZE_OPTIONS = SIZE_MAPPINGS.keys

  # Initialize the AvatarComponent with provided options.
  #
  # @param src [String] The source URL of the avatar image.
  # @param alt [String, nil] The alt text for the image (optional).
  # @param scheme [Symbol] The shape scheme for the avatar (optional, default: :round).
  # @param size [Symbol] The size of the avatar (optional, default: :medium).
  # @param classes [String, nil] Additional custom CSS classes (optional).
  def initialize(src:, alt: nil, scheme: DEFAULT_SCHEME, size: DEFAULT_SIZE, classes: nil)
    @src = src
    @alt = alt
    @classes = build_classes(classes, scheme, size)
  end

  # Renders the avatar as an HTML <img> tag with the generated classes.
  #
  # @return [String] HTML-safe string representing the <img> tag for the avatar.
  def call
    image_tag @src, alt: @alt, class: @classes, role: "img"
  end

  private

  # Builds the CSS class string for the avatar image, based on the provided scheme, size, and custom classes.
  #
  # @param classes [String, nil] Additional CSS classes provided during initialization (optional).
  # @param scheme [Symbol] The shape scheme for the avatar.
  # @param size [Symbol] The size of the avatar.
  # @return [String] The combined CSS class string for the image element.
  def build_classes(classes, scheme, size)
    base_classes = [
      SCHEME_MAPPINGS.fetch(fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)),
      SIZE_MAPPINGS.fetch(fetch_or_fallback(SIZE_OPTIONS, size, DEFAULT_SIZE))
    ]

    class_names(base_classes.compact, classes.presence)
  end
end
