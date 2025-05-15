# frozen_string_literal: true

module TendrilTasks
  module Navigation
    # Renders the user's avatar with a dropdown menu
    class AvatarDropdownMenu < TendrilTasks::Component
      style :avatar, "p-0.5 sm:h-14 sm:w-14 bg-gradient-to-br from-blue-500 to-purple-600 drop-shadow"

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
