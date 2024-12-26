# frozen_string_literal: true

module TendrilTasks
  module Projects
    class Section < TendrilTasks::Component
      with_collection_parameter :collection_item

      def initialize(project = nil, **options)
        @project = options.delete(:collection_item) ||
          project ||
          (raise ArgumentError, "project is required")
      end
    end
  end
end
