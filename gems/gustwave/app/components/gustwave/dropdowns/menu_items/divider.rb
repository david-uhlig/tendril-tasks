# frozen_string_literal: true

module Gustwave
  module Dropdowns
    module MenuItems
      # Use Divider to separate blocks of menu items
      #
      # @status alpha
      class Divider < Gustwave::Dropdowns::MenuItems::Base
        part :root, "my-1 h-px bg-gray-100 dark:bg-gray-700 w-full"

        option :tag, default: :div, values: %i[div span]

        # @param tag [Symbol] Defaults to +:div+. Valid values are +:div+ and +:span+.
        # @param options [Hash] the HTML attributes of the divider.
        def initialize(tag: DEFAULT, **options)
          select_options(tag:)
          @divider_tag = option_value(:tag)
          @config = attributes_for(options)
        end

        def call
          content_tag divider_tag, nil, { role: "separator", **config }
        end

        private
        attr_reader :config, :divider_tag
      end
    end
  end
end
