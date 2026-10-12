# frozen_string_literal: true

module TendrilTasks
  module Tasks
    # Display a short task summary, e.g. on the home page.
    #
    # Unlike +TendrilTasks::Tasks::Card+, it shows only the first lines of the
    # description, the contact people's avatars and a single button to express
    # interest.
    #
    # Example usage:
    #
    #   <%= render TendrilTasks::Tasks::CompactCard.new(task) %>
    #
    class CompactCard < TendrilTasks::Component
      VISIBLE_CONTACTS = 3
      NAMED_CONTACTS = 2

      # @param task [Task] the task to be displayed
      def initialize(task)
        @task = task
      end

      # @return [Boolean] true if the task was created within the last 2 weeks
      def is_new?
        @task.new?
      end

      # @return [Boolean] true if the signed in user applied to the task
      def applied?
        current_user.applied_to?(@task)
      end

      # @return [String] the id of the modal listing the contact people
      def modal_id
        "task-compact-card-contacts-#{@task.id}"
      end

      # Names the first contact people by their first names and counts the
      # rest, e.g. "Pete, Igor and 2 more".
      #
      # @return [String] the names joined as a sentence in the current locale
      def contact_names
        coordinators = @task.coordinators.to_a
        names = coordinators.first(NAMED_CONTACTS).map { |coordinator| first_name(coordinator) }
        others = coordinators.size - names.size
        names << t(".others", count: others) if others.positive?
        names.to_sentence
      end

      private

      # The first word of the name, which comes from Rocket.Chat, or the
      # username when the name is blank.
      def first_name(user)
        user.name.split.first.presence || user.username
      end
    end
  end
end
