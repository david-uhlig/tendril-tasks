# frozen_string_literal: true

module TendrilTasks
  module Admin
    class Card < TendrilTasks::Component
      style :heading,
            "mb-0"

      style :hyphens,
            "hyphens-auto"

      style :button,
            "w-full justify-center"

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

      renders_many :badges, ->(text = nil, icon: nil, **options, &block) do
        config = configure_component(
          options,
          pill: true,
          lang: I18n.locale
        )
        component = Gustwave::Badge.new(text, **config, &block)
        component.leading_icon(icon, class: "me-0.5") if icon
        component
      end
      alias badge with_badge

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

      renders_many :buttons, ->(href:, **options, &block) do
        options.symbolize_keys!
        options[:href] = href
        options[:tag] ||= :a
        options[:size] ||= :lg
        options[:class] = styles(button: true,
                                 custom: options[:class])

        Gustwave::Button.new(**options) do
          capture(&block)
        end
      end
      alias button with_button
    end
  end
end
