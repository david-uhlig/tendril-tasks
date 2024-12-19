# frozen_string_literal: true

# Renders an avatar image with customizable options for shape, size, and additional styling.
#
# @!attribute [r] DEFAULT_SCHEME
#   @return [Symbol] The default shape scheme applied to the avatar (:round).
#
# @!attribute [r] SCHEME_MAPPINGS
#   @return [Hash{Symbol => String}] A mapping of shape schemes to their corresponding CSS classes.
#     - :round   -> "rounded-full" (circular avatar)
#     - :square  -> "rounded" (square avatar with slight rounding)
#
# @!attribute [r] DEFAULT_SIZE
#   @return [Symbol] The default size of the avatar (:medium).
#
# @!attribute [r] SIZE_MAPPINGS
#   @return [Hash{Symbol => String}] A mapping of size options to their corresponding width/height CSS classes.
#     - :extra_small -> "w-6 h-6"
#     - :small       -> "w-8 h-8"
#     - :medium      -> "w-10 h-10"
#     - :large       -> "w-20 h-20"
#     - :extra_large -> "w-36 h-36"
#
# @param user [User] The source URL of the avatar image.
# @param alt [String, nil] The alt text for the image (optional, defaults to nil).
# @param scheme [Symbol] The shape scheme for the avatar (optional, default: :round).
# @param size [Symbol] The size of the avatar (optional, default: :medium).
# @param classes [String, nil] Additional CSS classes to apply (optional).
# @param options [Hash, nil] Extra HTML attributes for the <img> tag (optional).
# @return [void]
#
# == Example Usage:
#   <%= render AvatarComponent.new(
#     user: User.first,
#     scheme: :square,
#     size: :large,
#     classes: "border-2 border-blue-500"
#   ) %>
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
    extra_large: "w-36 h-36",
    custom: ""
  }.freeze
  SIZE_OPTIONS = SIZE_MAPPINGS.keys

  # Initialize the AvatarComponent with provided options.
  #
  # @param user [User] The user for whom the avatar is shown.
  # @param scheme [Symbol] The shape scheme for the avatar (optional, default: :round).
  # @param size [Symbol] The size of the avatar (optional, default: :medium).
  # @param options [Hash, nil] Additional HTML attributes for the image element (optional).
  def initialize(user, scheme: DEFAULT_SCHEME, size: DEFAULT_SIZE, **options)
    @src = user.avatar_url
    @options = build_options(scheme, size, **options)
  end

  # Renders the avatar as an HTML <img> tag with the appropriate options.
  #
  # @return [String] HTML-safe string representing the <img> tag for the avatar.
  def call
    image_tag @src, @options
  end

  private

  # Builds the options hash for the image tag, merging default and custom options.
  #
  # @param scheme [Symbol] Shape scheme for the avatar.
  # @param size [Symbol] Size of the avatar.
  # @param options [Hash] Options hash for HTML attributes.
  # @return [Hash] The final options hash for the image tag.
  def build_options(scheme, size, **options)
    options.deep_symbolize_keys!
    options[:class] = class_merge(
      SCHEME_MAPPINGS[fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)],
      SIZE_MAPPINGS[fetch_or_fallback(SIZE_OPTIONS, size, DEFAULT_SIZE)],
      options.delete(:class)
    )
    options[:role] ||= "img"
    options
  end
end
