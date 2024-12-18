# frozen_string_literal: true

module Form
  # Render a full-width large submit button in forms
  class ButtonComponent < ApplicationComponent
    DEFAULT_CLASS = "w-full"
    TAG = :button
    TYPE = :submit

    def initialize(scheme: ::ButtonComponent::DEFAULT_SCHEME, size: :large, **options)
      @scheme = scheme
      @size = size
      @options = build_options(options)
    end

    def call
      render ::ButtonComponent.new(tag: TAG, type: TYPE, scheme: @scheme, size: @size, **@options) do
        content
      end
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:class] = class_names(DEFAULT_CLASS, options.delete(:class))
      options
    end
  end
end
