# frozen_string_literal: true

module TendrilTasks
  module Elements
    # Displays the published state of a task or project with a badge
    class PublishedStateInfo < TendrilTasks::Component
      # @param [Task, Project] element
      def initialize(element)
        @element = element
      end

      def call
        if published?
          render Gustwave::Badge.new(t(".states.published"),
                                     color: :green,
                                     size: :md,
                                     class: "me-1") do |badge|
            badge.with_leading_visual_icon :lock_open
          end
        else
          render Gustwave::Badge.new(t(".states.draft"),
                                     color: :dark,
                                     size: :md,
                                     class: "me-1") do |badge|
            badge.with_leading_visual_icon :lock
          end
        end
      end

      private

      def published?
        @published ||= @element.published?
      end
    end
  end
end
