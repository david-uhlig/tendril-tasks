# frozen_string_literal: true

module TendrilTasks
  class Paragraph < TendrilTasks::Component
    style :base,
          "text-lg font-normal text-gray-500 lg:text-xl dark:text-gray-400"

    style :size,
          states: {
            lg: "text-lg font-normal lg:text-xl"
          },
          default: :lg

    def initialize(text = nil, size: default_layer_state(:size), **options)
      @text = text

      options.symbolize_keys!
      options[:class] = styles(base: true,
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
