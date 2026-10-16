# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      class Toolbar < Gustwave::Component
        base "flex items-center space-x-1 rtl:space-x-reverse flex-wrap"

        # The HTML tag, the custom element of the editor's toolbar
        option :tag, default: :div, values: %i[div trix-toolbar lexxy-toolbar]

        def initialize(tag: DEFAULT, **options)
          select_options(tag:)
          @tag = option_value(:tag)

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
