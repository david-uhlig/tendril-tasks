# frozen_string_literal: true

module TendrilTasks
  # Use NewItemBadge to indicate that something is new with a badge.
  #
  # Renders a green, pill-shaped badge with the i18n text "New" by default.
  class NewItemBadge < TendrilTasks::Component
    # A bordered badge turns gray in dark mode, this one stays green.
    base "opacity-80 dark:bg-green-900 dark:text-green-300"

    def initialize(text = nil,
                   color: :green,
                   size: :xs,
                   pill: true,
                   border: true,
                   **options)
      @text = text
      @options = { color:, size:, pill:, border: }.compact.merge!(attributes_for(options))
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
