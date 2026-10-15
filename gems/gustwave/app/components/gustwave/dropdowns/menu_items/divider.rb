# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module MenuItems
      # Use Divider to separate blocks of menu items
      class Divider < Gustwave::Dropdowns::MenuItems::Base
        base "my-1 h-px bg-gray-100 dark:bg-gray-700 w-full"

        def initialize(tag: :div, **options)
          @divider_tag = tag
          @config = attributes_for(options)
        end

        def call
          content_tag divider_tag, nil, config
        end

        private
        attr_reader :config, :divider_tag
      end
    end
  end
end
