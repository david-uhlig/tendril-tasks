# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Lexxy
        # Renders a toolbar button that dispatches a Lexxy editor command.
        #
        # The +name+ attribute lets Lexxy toggle +aria-pressed+ and
        # +aria-disabled+ on the button to reflect the editor state.
        class Button < Gustwave::Component
          ATTRIBUTE_COMMAND_MAPPINGS = {
            bold: "bold",
            italic: "italic",
            strike: "strikethrough",
            underline: "underline",
            heading1: "applyHeadingFormat",
            heading2: "applyHeadingFormat",
            heading3: "applyHeadingFormat",
            heading4: "applyHeadingFormat",
            quote: "insertQuoteBlock",
            code: "insertCodeBlock",
            bullet: "insertUnorderedList",
            number: "insertOrderedList",
            table: "insertTable",
            horizontal_rule: "insertHorizontalDivider",
            attach_files: "uploadFile",
            undo: "undo",
            redo: "redo"
          }.freeze

          # Button names Lexxy uses to look up buttons in its toolbar
          ATTRIBUTE_NAME_MAPPINGS = {
            strike: "strikethrough",
            bullet: "unordered-list",
            number: "ordered-list",
            horizontal_rule: "divider",
            attach_files: "file"
          }.freeze

          ATTRIBUTE_PAYLOAD_MAPPINGS = {
            heading1: "h1",
            heading2: "h2",
            heading3: "h3",
            heading4: "h4"
          }.freeze

          def initialize(attribute, icon_or_text: nil, disabled: false, **options)
            @attribute = attribute.downcase.to_sym

            options.deep_symbolize_keys!
            options[:icon_or_text] = icon_or_text
            options[:disabled] = disabled
            options[:name] ||= ATTRIBUTE_NAME_MAPPINGS.fetch(@attribute, @attribute.to_s)
            unless disabled.present?
              options[:"data-command"] ||= ATTRIBUTE_COMMAND_MAPPINGS[@attribute]
              options[:"data-payload"] ||= ATTRIBUTE_PAYLOAD_MAPPINGS[@attribute]
            end
            @options = options.compact
          end

          def call
            render(
              Gustwave::Form::RichText::Button.new(@attribute, **@options) do
                content
              end
            )
          end
        end
      end
    end
  end
end
