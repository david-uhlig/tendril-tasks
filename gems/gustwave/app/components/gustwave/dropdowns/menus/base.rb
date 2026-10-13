# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module Menus
      # Use Base as a base class for building dropdown menus
      #
      # Renders optional header and footer slots, and a content area in between.
      # Provides consistent base styling. Can be placed in any content area with
      # the +content_for+ argument.
      #
      # Inherit from this class when your menu needs extended behavior or
      # configuration. To customize, add content slots, overwrite the call
      # method, and add or overwrite the styles.
      #
      # For consistency, do not use this class directly in the UI. Instead, use
      # Gustwave::Dropdowns::Menus::Generic
      class Base < Gustwave::Component
        style :base, "z-10 bg-white divide-y divide-gray-100 rounded-lg shadow-md w-auto dark:bg-gray-700 hidden"

        style :header, "px-4 py-2 text-sm text-gray-900 dark:text-white"

        style :footer, "px-4 py-2 text-sm text-gray-900 dark:text-white"

        # Use the +header+ slot to customize the header of the dropdown menu
        #
        # When the header slot is absent, no header will be rendered.
        #
        # @param text [String, nil] the text to appear in the header. Takes precedent over block content.
        # @param tag [Symbol] HTML tag to use for the header. Default: +header+.
        # @param options [Hash] additional HTML attributes passed to the surrounding HTML element.
        renders_one :header_slot, ->(text = nil, tag: :header, **options, &block) do
          config = configure_html_attributes(options, class: styles(header: true))
          content_tag tag, **config do
            text || capture(&block)
          end
        end
        alias header with_header_slot

        # Use the +footer+ slot to customize the footer of the dropdown menu
        #
        # When the footer slot is absent, no footer will be rendered.
        #
        # @param text [String, nil] the text to appear in the footer. Takes precedent over block content.
        # @param tag [Symbol] HTML tag to use for the footer. Default: +footer+.
        # @param options [Hash] additional HTML attributes passed to the surrounding HTML element.
        renders_one :footer_slot, ->(text = nil, tag: :footer, **options, &block) do
          config = configure_html_attributes(options, class: styles(footer: true))
          content_tag tag, **config do
            text || capture(&block)
          end
        end
        alias footer with_footer_slot

        # @param text [String, nil] the text to appear in the dropdown menu. Takes precedent over block content.
        # @param id [String] the id attribute for the dropdown menu. Must match the id attribute called by the triggering element.
        # @param content_for [Symbol, nil] the name of the content area to render the menu. If +nil+, the menu is rendered right after the triggering element.
        # @param tag [Symbol] HTML tag to use for the dropdown menu. Default: +div+.
        # @param options [Hash] additional HTML attributes passed to the surrounding HTML element.
        def initialize(text = nil, id:, content_for: nil, tag: :div, **options)
          @text = text
          @menu_tag = tag
          @config = configure_component(
            options,
            id:,
            class: styles(base: true)
          )
          @content_for_name = content_for
        end

        def call
          content_for_wrapper do
            content_tag menu_tag, **config do
              safe_join([ header_slot, text_or_content, footer_slot ])
            end
          end
        end

        private
        attr_reader :text, :menu_tag, :config, :content_for_name

        def content_for_wrapper(&block)
          return capture(&block) unless content_for_name?

          content_for(content_for_name, &block)
        end

        def content_for_name?
          content_for_name.present?
        end
      end
    end
  end
end
