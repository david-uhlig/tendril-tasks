# frozen_string_literal: true

module TendrilTasks
  class Content < TendrilTasks::Component
    variant :width, default: :full, values: {
      full: "",
      large: "mx-auto sm:px-16 xl:px-24 space-y-6"
    }

    def initialize(width: DEFAULT, **options)
      style_with(width:)
      @options = attributes_for(options)
    end

    def call
      if @options.compact.empty?
        content
      else
        content_tag :div, **@options do
          content
        end
      end
    end
  end
end
