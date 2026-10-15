# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module MenuItems
      class Base < Gustwave::Component
        base "flex items-center gap-1.5 w-full px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white whitespace-nowrap"

        part :flex_grow, "grow text-left"

        private

        def flex_grow(text = nil, tag: :span, &block)
          return nil unless text || block_given?

          content_tag tag, class: classes(:flex_grow) do
            text || capture(&block)
          end
        end
      end
    end
  end
end
