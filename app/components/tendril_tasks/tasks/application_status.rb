# frozen_string_literal: true

module TendrilTasks
  module Tasks
    # Display the status of an application.
    #
    # This component renders different icons and styles based on the
    # application's status.
    #
    # Example usage:
    #
    #   <%= render TendrilTasks::Tasks::ApplicationStatus.new(application) %>
    #
    class ApplicationStatus < TendrilTasks::Component
      # The dropdown button showing the current status
      part :trigger, "focus:ring-4 focus:outline-hidden focus:ring-gray-300 font-medium rounded-full text-sm p-2.5 text-center inline-flex items-center ms-2"

      variant :status, part: :trigger, default: :received, internal: true, values: {
        received: "bg-gray-100 text-gray-800",
        under_review: "bg-cyan-100 text-cyan-800",
        interviewing: "bg-blue-100 text-blue-800",
        on_hold: "bg-yellow-100 text-yellow-800",
        accepted: "bg-green-100 text-green-800",
        rejected: "bg-red-100 text-red-800",
        withdrawn: "bg-indigo-100 text-indigo-800"
      }

      derive :icon, from: :status, values: {
        received: :inbox,
        under_review: :file_search,
        interviewing: :messages,
        on_hold: :clock,
        accepted: :badge_check,
        rejected: :close_circle,
        withdrawn: :ban
      }

      # Initializes a new ApplicationStatus component.
      #
      # @param application [TaskApplication] the application whose status is to be displayed
      def initialize(application)
        @application = application
        select_options(status: application.status)
      end

      private

      def render_icon_for(status)
        render Gustwave::Icon.new(derived_value(:icon, status:), position: :standalone)
      end
    end
  end
end
