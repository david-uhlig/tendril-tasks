# frozen_string_literal: true

module TendrilTasks
  module Elements
    class VisibilityExplainer < TendrilTasks::Component
      style :quick_info_line,
            default: :on,
            states: {
              on: "h-1 bg-green-300 dark:bg-green-400",
              off: "h-1 bg-gray-200 dark:bg-gray-600"
            }

      style :icon,
            default: :on,
            states: {
              on: "text-green-400 dark:text-green-500",
              off: "text-gray-400 dark:text-gray-500"
            }

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
        tag.div class: styles(quick_info_line: condition)
      end

      def checkmark_icon
        render Gustwave::Icon.new(:check,
                                  size: :sm,
                                  class: styles(icon: :on))
      end

      def cross_icon
        render Gustwave::Icon.new(:close,
                                  size: :sm,
                                  class: styles(icon: :off))
      end
    end
  end
end
