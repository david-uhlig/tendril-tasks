# frozen_string_literal: true

module TendrilTasks
  class Content < TendrilTasks::Component
    style_layer :width, {
      full: "",
      large: "mx-auto sm:px-16 xl:px-24 space-y-6"
    }, default: :full

    def initialize(width: default_layer_state(:width), **options)
      options.symbolize_keys!
      options[:class] = merge_layers(
        width: width,
        custom: options.delete(:class)
      ).presence
      @options = options
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

    private

    def build_options(width, options)
      options.deep_symbolize_keys!
      options[:class] = class_merge(
        WIDTH_MAPPINGS[fetch_or_fallback(WIDTH_OPTIONS, width, DEFAULT_WIDTH)],
        options.delete(:class)
      )
      options[:class] = nil if options[:class].empty?
      options
    end
  end
end
