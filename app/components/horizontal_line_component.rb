# frozen_string_literal: true

class HorizontalLineComponent < ApplicationComponent
  DEFAULT_CLASS = "hidden sm:flex h-px my-8 bg-gray-200 border-0 dark:bg-gray-700"

  def initialize(**options)
    @options = build_options(options)
  end

  def call
    tag.hr **@options
  end

  private

  def build_options(options)
    options.deep_symbolize_keys!
    options[:class] = class_names(DEFAULT_CLASS, options.delete(:class))
    options
  end
end
