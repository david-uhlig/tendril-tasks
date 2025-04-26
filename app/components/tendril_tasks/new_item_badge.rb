# frozen_string_literal: true

module TendrilTasks
  # Use NewItemBadge to indicate that something is new with a badge.
  #
  # Renders a green, pill-shaped badge with the i18n text "New" by default.
  class NewItemBadge < TendrilTasks::Component
    style :base, "opacity-80"

    def initialize(text = nil,
                   scheme: :green,
                   size: :xs,
                   pill: true,
                   border: true,
                   **options)
      options.symbolize_keys!
      options[:class] = styles(base: true, custom: options.delete(:class))
      kwargs = { scheme:, size:, pill:, border: }.compact

      @text = text
      @options = kwargs.merge!(options)
    end

    def before_render
      @text = t("badges.new") if text.blank?
    end

    def call
      render Gustwave::Badge.new(text, **options)
    end

    private
    attr_reader :options, :text
  end
end
