# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Trix
        class Button < Gustwave::Component
          ATTRIBUTE_KEY_MAPPINGS = {
            bold: "b",
            italic: "i",
            href: "k",
            undo: "z",
            redo: "shift+z"
          }.freeze

          ATTRIBUTE_ACTION_MAPPINGS = {
            delete_me_href: "link",
            undo: "undo",
            redo: "redo",
            increase_nesting: "increaseNestingLevel",
            decrease_nesting: "decreaseNestingLevel",
            attach_files: "attachFiles"
          }.freeze

          def initialize(attribute, icon_or_text: nil, key: nil, disabled: false, **options)
            @attribute = attribute.downcase.to_sym
            key ||= ATTRIBUTE_KEY_MAPPINGS[attribute]

            options.deep_symbolize_keys!
            options[:icon_or_text] = icon_or_text
            options[:disabled] = disabled
            unless disabled.present?
              options[:"data-trix-attribute"] ||= attribute.to_s
              options[:"data-trix-key"] ||= key
              options[:"data-trix-action"] ||= ATTRIBUTE_ACTION_MAPPINGS[attribute]
            end
            @options = options
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
