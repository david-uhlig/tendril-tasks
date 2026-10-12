# frozen_string_literal: true

module TendrilTasks
  module Navigation
    # The site's label next to the logo: a thin divider, then the label in bold.
    class BrandLabel < TendrilTasks::Component
      def initialize(site)
        @site = site
      end

      # Hidden while the menu is collapsed, leaving room for the logo.
      def call
        safe_join([
          tag.span(aria: { hidden: true }, class: "hidden md:block w-px h-8 bg-gray-300 dark:bg-gray-600"),
          link_to(site.navigation_label,
                  root_path,
                  class: "hidden md:block text-2xl font-bold tracking-tight text-gray-900 truncate rounded-sm hover:text-blue-700 dark:text-white dark:hover:text-blue-500")
        ])
      end

      def render?
        site.display_navigation_label?
      end

      private

      attr_reader :site
    end
  end
end
