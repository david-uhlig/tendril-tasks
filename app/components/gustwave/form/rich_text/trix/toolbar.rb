# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      module Trix
        class Toolbar < Gustwave::Component
          ACTION_GROUPS = [
            %i[bold italic strike link],
            %i[heading1 heading2 heading3 heading4 heading5 heading6],
            %i[quote code bullet number decrease_nesting increase_nesting],
            %i[attach_files],
            %i[undo redo]
          ].freeze
          ACTION_OPTIONS = ACTION_GROUPS.flatten.freeze

          def initialize(form, id: "custom-toolbar", hidden: [], disabled: [], **options)
            @id = id
            @form = form
            @hidden = [ hidden ].flatten.compact
            @disabled = [ disabled ].flatten.compact
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
        end
      end
    end
  end
end
