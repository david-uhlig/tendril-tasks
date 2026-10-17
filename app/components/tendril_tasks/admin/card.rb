# frozen_string_literal: true

module TendrilTasks
  module Admin
    class Card < TendrilTasks::Component
      part :heading, "mb-0 hyphens-auto"

      part :paragraph, "hyphens-auto"

      part :button, "w-full justify-center"

      renders_one :heading, ->(text = nil, **options, &block) do
        options = attributes_for(:heading, options)
        options[:tag] ||= :h2
        options[:size] ||= :md
        options[:lang] ||= I18n.locale
        TendrilTasks::Heading.new(text, **options) do
          capture(&block)
        end
      end

      renders_many :badges, ->(text = nil, icon: nil, **options, &block) do
        config = configure_html_attributes(
          options,
          pill: true,
          lang: I18n.locale
        )
        component = Gustwave::Badge.new(text, **config, &block)
        component.with_leading_visual_icon(icon, class: "me-0.5") if icon
        component
      end

      renders_many :paragraphs, ->(**options, &block) do
        options = attributes_for(:paragraph, options)
        options[:size] ||= :sm
        options[:lang] ||= I18n.locale
        TendrilTasks::Paragraph.new(**options) do
          capture(&block)
        end
      end

      renders_many :buttons, ->(href:, **options, &block) do
        options = attributes_for(:button, options)
        options[:href] = href
        options[:tag] ||= :a
        options[:size] ||= :lg

        Gustwave::Button.new(**options) do
          capture(&block)
        end
      end
    end
  end
end
