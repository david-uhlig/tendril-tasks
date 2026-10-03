# frozen_string_literal: true

module TendrilTasks
  # Use ListRow to render a list item as a row with an optional leading
  # visual, a title and trailing actions.
  #
  # The block's content, apart from the slots, is rendered as the trailing
  # actions.
  #
  #   <%= render TendrilTasks::ListRow.new(id: "user-#{user.id}") do |row| %>
  #     <% row.leading do %>
  #       <%= render TendrilTasks::Avatar.new(user) %>
  #     <% end %>
  #     <% row.title user.name %>
  #
  #     <%= render Gustwave::Button.new(t(".edit")) %>
  #   <% end %>
  #
  # @param options [Hash] HTML attributes passed to the +li+ element.
  class ListRow < TendrilTasks::Component
    style :row,
          "flex items-center p-3 text-base font-bold text-gray-900 rounded-lg bg-gray-50 dark:bg-gray-600 dark:text-white"

    style :title,
          "flex-1 ms-3 font-medium dark:text-white whitespace-nowrap truncate"

    # Use the +leading+ slot for a visual in front of the title, e.g. an avatar.
    renders_one :leading_slot
    alias leading with_leading_slot

    # Use the +title+ slot for the row's text, passed as an argument or a block.
    #
    # @param text [String] the title, unless given as a block.
    # @param options [Hash] HTML attributes passed to the +span+ element.
    renders_one :title_slot, ->(text = nil, **options, &block) do
      options.symbolize_keys!
      options[:class] = styles(title: true, custom: options.delete(:class))
      tag.span(block ? capture(&block) : text, **options)
    end
    alias title with_title_slot

    def initialize(**options)
      @options = options
    end
  end
end
