# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      class Toolbar < Gustwave::Component
        DEFAULT_TAG = :div

        base "flex items-center space-x-1 rtl:space-x-reverse flex-wrap"

        def initialize(tag: DEFAULT_TAG, **options)
          @tag = tag.to_sym

          @options = attributes_for(options)
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
