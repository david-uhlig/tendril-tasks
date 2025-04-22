# frozen_string_literal: true

module Gustwave
  # Use AvatarGroup to render an overlapping group of avatars.
  #
  # This component is useful for displaying a list of users or items in a
  # compact format. Supply Avatar, AvatarPlaceholder and AvatarText components
  # as block content. You can freely mix and match these components.
  #
  # === Basic Usage
  #
  #  <%= render Gustwave::AvatarGroup.new do %>
  #    <%= render Gustwave::Avatar.new(src: "https://example.com/avatar1.png") %>
  #    <%= render Gustwave::Avatar.new(src: "https://example.com/avatar2.png") %>
  #    <%= render Gustwave::AvatarPlaceholder.new %>
  #    <%= render Gustwave::AvatarText.new(text: "+5") %>
  #  <% end %>
  #
  # @param options [Hash] HTML attributes passed to the div element.
  class AvatarGroup < Gustwave::Component
    style :base,
          "flex -space-x-4 rtl:space-x-reverse"

    def initialize(**options)
      options.deep_symbolize_keys!

      config = {
        base: true,
        custom: options.delete(:class)
      }.compact_blank

      options[:class] = styles(**config)
      @options = options
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
