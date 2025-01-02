# frozen_string_literal: true

module Form
  # Render a full-width large submit button in forms
  class ButtonComponent < TendrilTasks::Component
    DEFAULT_CLASS = "w-full"
    DEFAULT_SCHEME = :default
    TAG = :button
    TYPE = :submit

    def initialize(scheme: DEFAULT_SCHEME, size: :lg, **options)
      @scheme = scheme
      @size = size
      @options = build_options(options)
    end

    def call
      render Gustwave::Button.new(tag: TAG,
                                  type: TYPE,
                                  scheme: @scheme,
                                  size: @size, **@options) do
        content
      end
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:class] = class_merge(DEFAULT_CLASS, options.delete(:class))
      options
    end
  end
end
