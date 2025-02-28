# frozen_string_literal: true

module TendrilTasks
  module Dashboard
    class Application < TendrilTasks::Component
      style :base,
            "bg-white border rounded-xl shadow-md dark:bg-gray-900 py-4 px-4 text-left flex flex-col sm:flex-row"

      style :disabled,
            "grayscale opacity-70"

      def initialize(application, **options)
        @application = application

        options.symbolize_keys!
        options[:class] = styles(base: true, disabled: !@application.task.visible?)
        @options = options
      end

      private

      def task_title_heading_with_link_if_visible
        optional_link_to_if(@application.task.visible?, @application.task) do
          render TendrilTasks::Heading.new(@application.task.title, tag: :h3, scheme: :level5)
        end
      end
    end
  end
end
