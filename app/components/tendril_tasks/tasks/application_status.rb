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
      # Maps status code to SVG icon identifier.
      ICON_MAPPINGS = {
        received: :inbox,
        under_review: :file_search,
        interviewing: :messages,
        on_hold: :clock,
        accepted: :badge_check,
        rejected: :close_circle,
        withdrawn: :ban
      }.freeze
      ICON_OPTIONS = ICON_MAPPINGS.keys

      # Maps status code to color scheme.
      CLASS_MAPPINGS = {
        received: "bg-gray-100 text-gray-800",
        under_review: "bg-cyan-100 text-cyan-800",
        interviewing: "bg-blue-100 text-blue-800",
        on_hold: "bg-yellow-100 text-yellow-800",
        accepted: "bg-green-100 text-green-800",
        rejected: "bg-red-100 text-red-800",
        withdrawn: "bg-indigo-100 text-indigo-800"
      }

      # Initializes a new ApplicationStatus component.
      #
      # @param application [TaskApplication] the application whose status is to be displayed
      def initialize(application)
        @application = application
        @statuses = TaskApplication.statuses
      end

      private

      def render_icon_for(status)
        icon = ICON_MAPPINGS[status.to_sym]
        render Gustwave::Icon.new(icon, position: :standalone)
      end

      def color_scheme_for(status)
        CLASS_MAPPINGS[status.to_sym]
      end
    end
  end
end
