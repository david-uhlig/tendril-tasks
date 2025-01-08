# frozen_string_literal: true

module TendrilTasks
  module Tasks
    # Display one application for a task.
    #
    # Example usage:
    #
    #   <%= render TendrilTasks::Tasks::Application.new(application) %>
    #
    class Application < TendrilTasks::Component
      # Duration for which an application is considered new.
      NEW_FOR = 1.week

      # @param application [Application] the application to be displayed
      def initialize(application)
        @application = application
      end

      def is_new?
        @application.created_at > NEW_FOR.ago
      end
    end
  end
end
