# frozen_string_literal: true

module Gustwave
  # Use AvatarGroup to render an overlapping group of avatars.
  #
  # The block holds the avatars, any mix of Avatar, AvatarPlaceholder and
  # AvatarText:
  #
  #  <%= render Gustwave::AvatarGroup.new do %>
  #    <%= render Gustwave::Avatar.new(src: "https://example.com/avatar1.png") %>
  #    <%= render Gustwave::Avatar.new(src: "https://example.com/avatar2.png") %>
  #    <%= render Gustwave::AvatarPlaceholder.new %>
  #    <%= render Gustwave::AvatarText.new("+5") %>
  #  <% end %>
  #
  # @status alpha
  class AvatarGroup < Gustwave::Component
    base "flex -space-x-4 rtl:space-x-reverse"

    # @param options [Hash] the HTML attributes of the +<div>+.
    def initialize(**options)
      @options = attributes_for(options)
    end

    def call
      tag.div(**options) do
        content
      end
    end

    private

    attr_reader :options
  end
end
