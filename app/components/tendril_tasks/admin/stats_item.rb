# frozen_string_literal: true

module TendrilTasks
  module Admin
    class StatsItem < TendrilTasks::Component
      def initialize(title, stats = {})
        @title = title
        @stats = stats
      end
    end
  end
end
