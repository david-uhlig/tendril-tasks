# frozen_string_literal: true

module TendrilTasks
  module Admin
    class Card < TendrilTasks::Component
      style :heading,
            "mb-0"

      style :hyphens,
            "hyphens-auto"

      renders_one :heading_slot, ->(text = nil, **options, &block) do
        options.symbolize_keys!
        options[:tag] ||= :h2
        options[:scheme] ||= :level4
        options[:class] = styles(heading: true,
                                 hyphens: true,
                                 custom: options[:class])
        options[:lang] ||= I18n.locale
        TendrilTasks::Heading.new(text, **options) do
          capture(&block)
        end
      end
      alias heading with_heading_slot

      renders_many :paragraphs, ->(**options, &block) do
        options.symbolize_keys!
        options[:size] ||= :sm
        options[:class] = styles(hyphens: true,
                                 custom: options[:class])
        options[:lang] ||= I18n.locale
        TendrilTasks::Paragraph.new(**options) do
          capture(&block)
        end
      end
      alias paragraph with_paragraph

      def initialize(href:)
        @href = href
      end
    end
  end
end
