# frozen_string_literal: true

# Renders an avatar within a dropdown for the user navigation menu.
# This component extends the functionality of the AvatarComponent by integrating dropdown-specific
# data attributes and button behavior for a navigation menu.
#
# This component is designed to be used in user dropdown menus in the application's navigation.
#
# @param src [String] The source URL of the avatar image.
# @param alt [String, nil] The alt text for the image (optional).
# @param scheme [Symbol] The shape scheme for the avatar (optional, default: AvatarComponent::DEFAULT_SCHEME).
# @param size [Symbol] The size of the avatar (optional, default: AvatarComponent::DEFAULT_SIZE).
# @param classes [String, nil] Additional custom CSS classes for styling (optional).
# @param options [Hash, nil] Extra HTML attributes for the button and the avatar (optional).
#   - Includes "id" set to "avatarButton" and ensures "data" attributes are used for dropdown functionality.
#
# == Data Attributes:
#   - data-dropdown-toggle: "userDropdown" (links the button to the dropdown menu)
#   - data-dropdown-placement: "bottom-start" (defines the dropdown's position relative to the button)
#
# == Example Usage:
#   <%= render Navigation::UserDropdown::AvatarComponent.new(
#     src: "https://example.com/avatar.jpg",
#     alt: "User's avatar",
#     size: :small,
#     classes: "border rounded-lg"
#   ) %>
#
class Navigation::UserDropdown::AvatarComponent < ApplicationComponent
  # Initialize the AvatarComponent for use in the user dropdown button.
  #
  # @param src [String] The source URL of the avatar image.
  # @param alt [String, nil] The alt text for the avatar image (optional, defaults to nil).
  # @param scheme [Symbol] The shape scheme for the avatar (optional, default: AvatarComponent::DEFAULT_SCHEME).
  # @param size [Symbol] The size of the avatar (optional, default: AvatarComponent::DEFAULT_SIZE).
  # @param classes [String, nil] Additional CSS classes to apply to the avatar (optional).
  # @param options [Hash, nil] Additional HTML options for the button and avatar (optional).
  #   - This includes ensuring an "id" of "avatarButton" and adding dropdown-specific data attributes.
  def initialize(src:, alt: nil, scheme: AvatarComponent::DEFAULT_SCHEME, size: AvatarComponent::DEFAULT_SIZE, classes: nil, options: nil)
    options ||= {}
    options = options.stringify_keys
    options["id"] = "avatarButton"
    options["type"] = "button"

    # Ensure "data" is a hash before merging dropdown-specific attributes.
    options["data"] = options.fetch("data", {}).tap do |data|
      raise ArgumentError, '"data" must be a hash' unless data.is_a?(Hash)
    end.merge({
                "dropdown-toggle": "userDropdown",
                "dropdown-placement": "bottom-start"
              })

    @options = {
      src: src,
      alt: alt,
      scheme: scheme,
      size: size,
      classes: classes,
      options: options
    }
  end

  # Renders the avatar for the user dropdown.
  #
  # @return [String] HTML-safe string representing the avatar image within the button element.
  def call
    render AvatarComponent.new(**@options)
  end
end
