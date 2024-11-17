# frozen_string_literal: true

class Modal::ParagraphComponent < ApplicationComponent
  DEFAULT_CLASS = "text-base leading-relaxed text-gray-500 dark:text-gray-400"

  def initialize(text = nil, **options)
    @text = text
    @options = parse_options(options)
  end

  def call
    tag.p **@options do
      @text || content
    end
  end

  private

  def parse_options(options)
    options.stringify_keys!
    options["class"] = class_names(DEFAULT_CLASS, options.delete("class"))
    options
  end
end
