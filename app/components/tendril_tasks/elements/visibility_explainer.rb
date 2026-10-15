# frozen_string_literal: true

module TendrilTasks
  module Elements
    class VisibilityExplainer < TendrilTasks::Component
      part :quick_info_line
      part :icon

      # Whether a condition for visibility is met
      toggle :met,
             on: { quick_info_line: "h-1 bg-green-300 dark:bg-green-400", icon: "text-green-400 dark:text-green-500" },
             off: { quick_info_line: "h-1 bg-gray-200 dark:bg-gray-600", icon: "text-gray-400 dark:text-gray-500" }

      # @param [Task, Project] element
      def initialize(element)
        @element = element
      end

      def render?
        can?(:coordinate, @element)
      end

      private

      def visible?
        @element.visible?
      end

      def published?
        @element.published?
      end

      def project_published?
        return nil unless @element.is_a?(Task)
        @element.project.published?
      end

      def has_one_published_task?
        return nil unless @element.is_a?(Project)
        @element.tasks.present? && @element.tasks.any?(&:published?)
      end

      # Displays a horizontal line indicating if the condition is met
      def quick_info_line(condition)
        tag.div class: classes(:quick_info_line, met: condition)
      end

      def checkmark_icon
        render Gustwave::Icon.new(:check,
                                  size: :sm,
                                  class: classes(:icon, met: true))
      end

      def cross_icon
        render Gustwave::Icon.new(:close,
                                  size: :sm,
                                  class: classes(:icon, met: false))
      end
    end
  end
end
