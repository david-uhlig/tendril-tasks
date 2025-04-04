# frozen_string_literal: true

# Renders an avatar within a dropdown for the user navigation menu.
# This component extends the functionality of the AvatarComponent by integrating dropdown-specific
# data attributes and button behavior for a navigation menu.
#
# This component is designed to be used in user dropdown menus in the application's navigation.
#
# @param user [User] The user for whom the avatar is shown.
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
#     user: User.first,
#     size: :small,
#     classes: "border rounded-lg"
#   ) %>
#
module Navigation
  module UserDropdown
    class AvatarComponent < TendrilTasks::Component
      # Initialize the AvatarComponent for use in the user dropdown button.
      #
      # @param user [User] The user for whom the avatar is shown.
      # @param scheme [Symbol] The shape scheme for the avatar (optional, default: AvatarComponent::DEFAULT_SCHEME).
      # @param size [Symbol] The size of the avatar (optional, default: AvatarComponent::DEFAULT_SIZE).
      # @param options [Hash, nil] Additional HTML options for the button and avatar (optional).
      #   - This includes ensuring an "id" of "avatarButton" and adding dropdown-specific data attributes.
      def initialize(user, scheme: TendrilTasks::Avatar::DEFAULT_SCHEME, size: TendrilTasks::Avatar::DEFAULT_SIZE, **options)
        @user = user
        @scheme = scheme
        @size = size
        @options = build_options(options)
      end

      # Renders the avatar for the user dropdown.
      #
      # @return [String] HTML-safe string representing the avatar image within the button element.
      def call
        render TendrilTasks::Avatar.new(@user, scheme: @scheme, size: @size, **@options)
      end

      private

      def build_options(options)
        options.deep_symbolize_keys!
        options[:id] = "avatarButton"
        options[:type] = "button"

        # Ensure "data" is a hash before merging dropdown-specific attributes.
        options[:data] = options.fetch(:data, {}).tap do |data|
          raise ArgumentError, '"data" must be a hash' unless data.is_a?(Hash)
        end.merge({
                    "dropdown-toggle": "userDropdown",
                    "dropdown-placement": "bottom-start"
                  })
        options
      end
    end
  end
end
