# frozen_string_literal: true

module TendrilTasks
  module Admin
    class ApplicationVersionBadge < TendrilTasks::Component
      def call
        render Gustwave::Badge.new(
          scheme: :dark,
          size: :md,
          pill: true,
          # The badge is a flex container, which drops whitespace between the links
          class: "align-top gap-1"
        ) do
          safe_join([ link_to_version, link_to_commit ].compact, " ")
        end
      end

      private

      def link_to_version
        link_to TendrilTasks::VERSION, "https://github.com/david-uhlig/tendril-tasks/releases/tag/v#{TendrilTasks::VERSION}"
      end

      def link_to_commit
        commit = AppConfig.git_commit
        return nil if commit.blank?

        # Wrapped, so the badge's flex gap doesn't space out the parentheses
        tag.span do
          safe_join([ "(", link_to(commit, "https://github.com/david-uhlig/tendril-tasks/commit/#{commit}"), ")" ])
        end
      end
    end
  end
end
