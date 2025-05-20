# frozen_string_literal: true

module Gustwave
  module Form
    class RichTextArea < Gustwave::Component
      style :toolbar_container_base,
            "px-3 py-2 border-b dark:border-gray-600 flex flex-wrap items-center bg-gray-50 rounded-t-lg border-t-red-200 dark:bg-gray-700"
      style :sticky_toolbar_container,
            "group-focus-within:sticky group-hover:sticky top-0 z-10"

      renders_one :toolbar_slot
      alias with_toolbar with_toolbar_slot
      alias toolbar with_toolbar_slot

      renders_one :editor_slot
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
        @toolbar_container_options = {
          class: styles(toolbar_container_base: true,
                        sticky_toolbar_container: sticky_toolbar)
        }
      end

      private

      def render_toolbar
        @render_toolbar ||= toolbar_slot? ? toolbar_slot : default_toolbar
      end

      def render_editor
        @render_editor ||= editor_slot? ? editor_slot : default_editor
      end

      def default_toolbar
        render Gustwave::Form::RichText::Trix::Toolbar.new(@form, **@toolbar_options)
      end

      def default_editor
        @form.rich_textarea @attribute,
                            toolbar: @toolbar_options[:id],
                            class: "block w-full text-sm px-0 text-gray-800 border-0 dark:bg-gray-800 dark:text-white dark:placeholder-gray-400 w-full min-h-80 focus:outline-none",
                            spellcheck: false
      end
    end
  end
end
