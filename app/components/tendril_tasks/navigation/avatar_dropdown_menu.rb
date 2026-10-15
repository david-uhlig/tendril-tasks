# frozen_string_literal: true

module TendrilTasks
  module Navigation
    # Renders the user's avatar with a dropdown menu
    class AvatarDropdownMenu < TendrilTasks::Component
      # A white ring with a soft shadow lifts the photo off the page
      part :avatar, "sm:h-14 sm:w-14 border-3 border-white ring-1 ring-gray-200 shadow-md dark:border-gray-900 dark:ring-gray-700"

      def render?
        user_signed_in?
      end

      private

      def show_admin_settings?
        @show_admin_settings ||= can?(:show, :admin_settings)
      end
    end
  end
end
