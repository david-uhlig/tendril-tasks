# frozen_string_literal: true

module TendrilTasks
  module Navigation
    class BrandBadge < TendrilTasks::Component
      def initialize(site, **options)
        @site = site
        @config = configure_component(
          options,
          tag: :a,
          size: "2xl",
          # Hidden while the menu is collapsed, leaving room for the logo.
          class: "hidden md:inline-flex text-2xl font-extrabold dark:bg-blue-200 dark:text-blue-800 truncate overflow-hidden",
        )
      end

      def before_render
        @config[:href] ||= root_path
      end

      def call
        render Gustwave::Badge.new(**config) do
          site.navigation_label
        end
      end

      def render?
        site.display_navigation_label?
      end

      private

      attr_reader :site, :config
    end
  end
end
