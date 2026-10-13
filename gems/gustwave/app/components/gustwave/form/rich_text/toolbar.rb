# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      class Toolbar < Gustwave::Component
        DEFAULT_TAG = :div

        style :base,
              "flex items-center space-x-1 rtl:space-x-reverse flex-wrap"

        def initialize(tag: DEFAULT_TAG, **options)
          @tag = tag.to_sym

          options.symbolize_keys!
          options[:class] = styles(base: true,
                                   custom: options.delete(:class))
          @options = options
        end

        def call
          content_tag @tag, **@options do
            content
          end
        end
      end
    end
  end
end
