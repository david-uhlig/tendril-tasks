# frozen_string_literal: true

module Gustwave
  module Form
    module RichText
      # Use `Divider` to separate blocks of buttons in a rich text toolbar
      class Divider < Gustwave::Component
        def call
          tag.div class: "px-1" do
            tag.span class: "block w-px h-4 bg-gray-300 dark:bg-gray-600"
          end
        end
      end
    end
  end
end
