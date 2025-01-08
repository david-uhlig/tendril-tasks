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
      # Mapping of status to their corresponding SVG icons.
      ICON_MAPPINGS = {
        received: Gustwave::Icon.new(:inbox, position: :trailing),
        under_review: Gustwave::Icon.new(:file_search, position: :trailing),
        interviewing: Gustwave::Icon.new(:messages, position: :trailing),
        on_hold: Gustwave::Icon.new(:clock, position: :trailing),
        accepted: Gustwave::Icon.new(:badge_check, position: :trailing),
        rejected: Gustwave::Icon.new(:close_circle, position: :trailing),
        withdrawn: Gustwave::Icon.new(:ban, position: :trailing)
      }.freeze
      ICON_OPTIONS = ICON_MAPPINGS.keys

      # Mapping of status to their corresponding CSS classes.
      CLASS_MAPPINGS = {
        received: "bg-gray-100 text-gray-800",
        under_review: "bg-blue-100 text-blue-800",
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
    end
  end
end
