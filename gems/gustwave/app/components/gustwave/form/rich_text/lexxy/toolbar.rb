# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Lexxy
        # Renders a custom +lexxy-toolbar+ for a Lexxy editor.
        #
        # Connect the toolbar to an editor by passing its +id+ to the editor's
        # +toolbar+ attribute.
        #
        # @status alpha
        class Toolbar < Gustwave::Component
          # The actions of the toolbar, in groups. A divider goes between the groups.
          ACTION_GROUPS = [
            %i[bold italic strike underline highlight link],
            %i[heading1 heading2 heading3 heading4],
            %i[quote code bullet number],
            %i[table horizontal_rule],
            %i[attach_files],
            %i[undo redo]
          ].freeze
          # Every action in ACTION_GROUPS, the values the +hidden+ and +disabled+ options take.
          ACTION_OPTIONS = ACTION_GROUPS.flatten.freeze

          # The heading actions, which the Stimulus heading controller turns into toggles.
          HEADING_ACTIONS = %i[heading1 heading2 heading3 heading4].freeze

          # @param form [ActionView::Helpers::FormBuilder, nil] the editor's form builder, as Gustwave::Form::RichTextarea passes it.
          # @param id [String, nil] the toolbar's id, for the editor's +toolbar+ attribute. Defaults to a random id.
          # @param hidden [Symbol, Array<Symbol>] the actions to leave out, from ACTION_OPTIONS.
          # @param disabled [Symbol, Array<Symbol>] the actions to disable, from ACTION_OPTIONS.
          # @param options [Hash] the HTML attributes of the +<div>+ around the toolbar.
          def initialize(form = nil, id: nil, hidden: [], disabled: [], **options)
            @id = id.presence || generate_random_id(prefix: "toolbar")
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

            { "data-gustwave--lexxy-heading-target": "button" }
          end
        end
      end
    end
  end
end
