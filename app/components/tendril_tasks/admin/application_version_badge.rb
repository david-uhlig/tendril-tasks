# frozen_string_literal: true

module TendrilTasks
  module Admin
    class ApplicationVersionBadge < TendrilTasks::Component
      def call
        render Gustwave::Badge.new(
          scheme: :dark,
          size: :md,
          pill: true,
          class: "align-top"
        ) do
          safe_join([ link_to_version, link_to_commit ])
        end
      end

      private

      def link_to_version
        link_to TendrilTasks::VERSION, "https://github.com/david-uhlig/tendril-tasks/releases"
      end

      def link_to_commit
        return nil unless AppConfig.git_commit.present?

        link_to AppConfig.git_commit, "https://github.com/david-uhlig/tendril-tasks/commit/#{AppConfig.git_commit}"
      end
    end
  end
end
