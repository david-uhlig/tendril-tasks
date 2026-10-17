# frozen_string_literal: true

module TendrilTasks
  class Paragraph < TendrilTasks::Component
    base "text-gray-500 dark:text-gray-400"

    variant :size, default: :lg, values: {
      sm: "text-sm font-normal lg:text-base",
      md: "text-base font-normal lg:text-lg",
      lg: "text-lg font-normal lg:text-xl"
    }

    toggle :hyphenated, "hyphens-auto"

    def initialize(text = nil, size: DEFAULT, hyphenated: true, **options)
      @text = text

      select_options(size:, hyphenated:)
      @options = attributes_for(options)
      @options[:lang] ||= I18n.locale if hyphenated
    end

    def call
      tag.p **@options do
        text_or_content(text)
      end
    end

    private

    attr_reader :text
  end
end
