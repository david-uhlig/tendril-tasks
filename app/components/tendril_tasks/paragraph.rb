# frozen_string_literal: true

module TendrilTasks
  class Paragraph < TendrilTasks::Component
    style :base,
          "text-gray-500 dark:text-gray-400"

    style :size,
          states: {
            sm: "text-sm front-normal lg:text-base",
            lg: "text-lg font-normal lg:text-xl"
          },
          default: :lg

    def initialize(text = nil, size: default_layer_state(:size), **options)
      @text = text

      options.symbolize_keys!
      options[:class] = styles(base: true,
                               size: size,
                               custom: options.delete(:class))
      @options = options
    end

    def call
      tag.p **@options do
        text_or_content
      end
    end
  end
end
