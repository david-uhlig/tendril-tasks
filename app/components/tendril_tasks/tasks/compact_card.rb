# frozen_string_literal: true

module TendrilTasks
  module Tasks
    # Display a short task summary in overviews, e.g. on the home page.
    #
    # It shows only the first lines of the description, the contact people's
    # avatars and a single button to express interest. Pass +detailed: true+
    # to show more of the description, e.g. on the task overview page.
    #
    # Example usage:
    #
    #   <%= render TendrilTasks::Tasks::CompactCard.new(task) %>
    #   <%= render TendrilTasks::Tasks::CompactCard.new(task, detailed: true) %>
    #
    class CompactCard < TendrilTasks::Component
      VISIBLE_CONTACTS = 3
      NAMED_CONTACTS = 2
      DESCRIPTION_WORDS = 30
      DETAILED_DESCRIPTION_WORDS = 50

      # @param task [Task] the task to be displayed
      # @param detailed [Boolean] show more of the description
      def initialize(task, detailed: false)
        @task = task
        @detailed = detailed
      end

      # @return [String, nil] the beginning of the plain text description
      def description
        words = @detailed ? DETAILED_DESCRIPTION_WORDS : DESCRIPTION_WORDS
        @task.description_plain_text&.truncate_words(words)
      end

      # @return [String] the CSS class limiting the visible description lines
      def description_clamp
        @detailed ? "line-clamp-5" : "line-clamp-3"
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
