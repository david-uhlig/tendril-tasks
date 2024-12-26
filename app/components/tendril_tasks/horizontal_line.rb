# frozen_string_literal: true

module TendrilTasks
  class HorizontalLine < TendrilTasks::Component
    DEFAULT_HIDDEN_BREAKPOINT = :sm
    HIDDEN_BREAKPOINT_OPTIONS = %i[sm md lg xl 2xl]

    def initialize(hide_below: DEFAULT_HIDDEN_BREAKPOINT, **options)
      @options = build_options(options, hide_below)
    end

    def call
      render Gustwave::HorizontalLine.new(**@options)
    end

    private

    def build_options(options, hide_below)
      options.deep_symbolize_keys!
      options[:class] = class_merge(
        build_responsive_classes(hide_below),
        options.delete(:class)
      )
      options
    end

    def build_responsive_classes(hide_below)
      return unless hide_below
      hide_below = fetch_or_fallback(HIDDEN_BREAKPOINT_OPTIONS, hide_below.to_sym, DEFAULT_HIDDEN_BREAKPOINT)
      "hidden #{hide_below}:flex"
    end
  end
end
