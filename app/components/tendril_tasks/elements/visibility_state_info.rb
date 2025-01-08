# frozen_string_literal: true

module TendrilTasks
  module Elements
    # Displays the visibility state of a task or project with a badge
    class VisibilityStateInfo < TendrilTasks::Component
      # @param [Task, Project] element
      def initialize(element)
        @element = element
      end

      def call
        if visible?
          render Gustwave::Badge.new(t(".states.visible"),
                                     scheme: :green,
                                     size: :md,
                                     class: "me-1") do |badge|
            badge.leading_icon :eye
          end
        else
          render Gustwave::Badge.new(t(".states.hidden"),
                                     scheme: :dark,
                                     size: :md,
                                     class: "me-1") do |badge|
            badge.leading_icon :eye_slash
          end
        end
      end

      private

      def visible?
        @visible ||= @element.visible?
      end
    end
  end
end
