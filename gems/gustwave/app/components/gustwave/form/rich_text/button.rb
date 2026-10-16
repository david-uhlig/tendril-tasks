# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      class Button < Gustwave::Component
        ATTRIBUTE_OPTIONS = %w[
          bold italic strike underline highlight bullet number quote code href
          link heading1 heading2 heading3 heading4 heading5 heading6
          increase_nesting decrease_nesting table horizontal_rule undo redo
          attach_files
        ].freeze

        ATTRIBUTE_VISUAL_MAPPINGS = {
          bold: :letter_bold,
          italic: :letter_italic,
          strike: :text_slash, # Text strikethrough
          underline: :letter_underline,
          highlight: :font_highlight, # Text color highlight
          bullet: :list, # Unordered list
          number: :ordered_list, # Ordered list
          quote: :quote, # Citation
          code: :code,
          href: :link,
          link: :link,
          heading1: "H1",
          heading2: "H2",
          heading3: "H3",
          heading4: "H4",
          heading5: "H5",
          heading6: "H6",
          increase_nesting: :indent,
          decrease_nesting: :outdent,
          table: :insert_table,
          horizontal_rule: :minus,
          undo: :undo,
          redo: :redo,
          attach_files: :paper_clip
        }.freeze

        base "p-1.5 text-gray-500 rounded-sm cursor-pointer hover:text-gray-900 hover:bg-gray-100 dark:text-gray-400 " \
             "dark:hover:text-white dark:hover:bg-gray-600 " \
             "disabled:text-gray-400 dark:disabled:text-gray-500 disabled:cursor-not-allowed"

        part :icon, "m-0 w-5 h-5"

        def initialize(attribute,
                       icon_or_text: nil,
                       disabled: false,
                       **options)
          attribute = attribute.downcase.to_sym
          icon_or_text ||= ATTRIBUTE_VISUAL_MAPPINGS[attribute]

          options.deep_symbolize_keys!
          options[:color] ||= :none
          options[:tabindex] ||= -1
          options[:disabled] = disabled.present? ? disabled : nil
          @icon_or_text = icon_or_text
          @options = attributes_for(options)
        end

        def call
          render Gustwave::Button.new(**@options) do
            if @icon_or_text.is_a?(String)
              concat @icon_or_text
              concat content
            else
              concat render(Gustwave::Icon.new(@icon_or_text, class: classes(:icon)))
              concat content
            end
          end
        end
      end
    end
  end
end
