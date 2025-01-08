# frozen_string_literal: true

class Modal::ParagraphComponent < TendrilTasks::Component
  DEFAULT_CLASS = "text-base leading-relaxed text-gray-500 dark:text-gray-400"

  def initialize(text = nil, **options)
    @text = text
    @options = build_options(options)
  end

  def call
    tag.p **@options do
      @text || content
    end
  end

  private

  def build_options(options)
    options.deep_symbolize_keys!
    options[:class] = class_merge(DEFAULT_CLASS, options.delete(:class))
    options
  end
end
