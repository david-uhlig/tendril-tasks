# frozen_string_literal: true

module TendrilTasks
  module Navigation
    class BrandBadge < TendrilTasks::Component
      def initialize(brand, **options)
        @brand = brand
        @config = configure_component(
          options,
          tag: :a,
          size: "2xl",
          class: "text-md sm:text-2xl font-normal sm:font-extrabold dark:bg-blue-200 dark:text-blue-800 truncate overflow-hidden",
        )
      end

      def before_render
        @config[:href] ||= root_path
      end

      def call
        render Gustwave::Badge.new(**config) do
          brand_name
        end
      end

      def render?
        brand.display_name?
      end

      private

      attr_reader :brand, :config

      def brand_name
        brand.name.presence || "Tendril Tasks"
      end
    end
  end
end
