# frozen_string_literal: true

module TendrilTasks
  module Elements
    class VisibilityInfoBar < TendrilTasks::Component
      def initialize(element)
        @element = element
      end

      def render?
        can?(:coordinate, @element)
      end

      def call
        tag.div class: "whitespace-nowrap m-auto" do
          concat render(TendrilTasks::Elements::PublishedStateInfo.new(@element))
          concat render(TendrilTasks::Elements::VisibilityStateInfo.new(@element))
          concat render(TendrilTasks::Elements::VisibilityExplainer.new(@element))
        end
      end
    end
  end
end
