# frozen_string_literal: true

module TendrilTasks
  module Tasks
    # Display task summary in overview elements.
    #
    # This component renders a card with task summary and a badge indicating the
    # task's initiative.
    #
    # Example usage:
    #
    #   <%= render TendrilTasks::Tasks::Card.new(task) %>
    #
    class Card < TendrilTasks::Component
      # Initializes a new Card component.
      #
      # @param task [Task] the task to be displayed
      # @param options [Hash] additional options for the card
      def initialize(task, **options)
        @task = task
        @options = build_options(options)
      end

      # Checks if the task is new.
      #
      # @return [Boolean] true if the task was created within the last 2 weeks, false otherwise
      def is_new?
        @task.created_at > 2.weeks.ago
      end

      private

      # Builds the options for the card.
      #
      # @param options [Hash] the options to be built
      # @return [Hash] the built options
      def build_options(options)
        options
      end
    end
  end
end
