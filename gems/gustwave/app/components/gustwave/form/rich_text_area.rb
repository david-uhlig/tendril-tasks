# frozen_string_literal: true

module Gustwave
  module Form
    class RichTextArea < Gustwave::Component
      part :toolbar_container,
           "px-3 py-2 border-b dark:border-gray-600 flex flex-wrap items-center bg-gray-50 rounded-t-lg border-t-red-200 dark:bg-gray-700"
      toggle :sticky_toolbar, part: :toolbar_container,
                              on: "group-focus-within:sticky group-hover:sticky top-0 z-10"

      renders_one_extensible :toolbar_slot, ->(&block) { block&.call }
      alias with_toolbar with_toolbar_slot
      alias toolbar with_toolbar_slot

      renders_one_extensible :editor_slot, ->(&block) { block&.call }
      alias with_editor with_editor_slot
      alias editor with_editor_slot

      def initialize(form = nil,
                     attribute = nil,
                     toolbar_id: nil,
                     sticky_toolbar: true,
                     **options)
        @form = form
        @attribute = attribute
        @toolbar_options = {
          id: toolbar_id.presence || generate_random_id(prefix: "toolbar")
        }
        select_options(sticky_toolbar:)
        @toolbar_container_options = { class: classes(:toolbar_container) }
      end

      private

      def render_toolbar
        @render_toolbar ||= toolbar_slot? ? toolbar_slot : default_toolbar
      end

      def render_editor
        @render_editor ||= editor_slot? ? editor_slot : default_editor
      end

      def default_toolbar
        render Gustwave::Form::RichText::Lexxy::Toolbar.new(@form, **@toolbar_options)
      end

      def default_editor
        @form.rich_textarea @attribute,
                            toolbar: @toolbar_options[:id],
                            class: "lexxy-content block w-full text-sm px-0 text-gray-800 border-0 dark:bg-gray-800 dark:text-white dark:placeholder-gray-400 w-full min-h-80 focus:outline-hidden",
                            spellcheck: false
      end
    end
  end
end
