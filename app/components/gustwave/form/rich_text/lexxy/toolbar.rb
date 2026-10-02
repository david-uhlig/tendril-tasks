# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Lexxy
        # Renders a custom +lexxy-toolbar+ for a Lexxy editor.
        #
        # Connect the toolbar to an editor by passing its +id+ to the editor's
        # +toolbar+ attribute.
        class Toolbar < Gustwave::Component
          ACTION_GROUPS = [
            %i[bold italic strike underline highlight link],
            %i[heading2 heading3 heading4],
            %i[quote code bullet number],
            %i[table horizontal_rule],
            %i[attach_files],
            %i[undo redo]
          ].freeze
          ACTION_OPTIONS = ACTION_GROUPS.flatten.freeze

          HEADING_ACTIONS = %i[heading2 heading3 heading4].freeze

          def initialize(form = nil, id: "custom-toolbar", hidden: [], disabled: [], **options)
            @id = id
            @form = form
            @hidden = [ hidden ].flatten.compact
            @disabled = [ disabled ].flatten.compact
            @options = options
            @actions = build_actions
          end

          private

          # Builds actions array
          #
          # Filters hidden actions from ACTION_GROUPS and adds dividers between
          # non-empty groups.
          #
          # @return [Array] a flat array of all non-hidden actions and dividers
          #   between groups
          def build_actions
            actions = [].tap do |arr|
              ACTION_GROUPS.each do |group|
                arr << group.reject { |action| hidden?(action) }
              end
            end

            actions
              .each_cons(2) { |group, _| group.push(:divider) unless group.empty? }
              .compact_blank
              .flatten
          end

          def hidden?(action)
            @hidden.include?(action.to_sym)
          end

          def disabled?(action)
            @disabled.include?(action.to_sym)
          end

          def button_options(action)
            return {} unless HEADING_ACTIONS.include?(action)

            { "data-lexxy-heading-target": "button" }
          end
        end
      end
    end
  end
end
