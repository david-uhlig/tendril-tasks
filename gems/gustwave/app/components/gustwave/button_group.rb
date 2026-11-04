# frozen_string_literal: true

module Gustwave
  # Use ButtonGroup to stack buttons together on a single line. The group sets
  # each button's position, so the first and last buttons get the outer
  # rounding and the middle buttons share their borders.
  #
  # === Example
  #
  # Renders a group of buttons:
  #
  #   <%= render Gustwave::ButtonGroup.new do |group| %>
  #     <% group.with_button("Profile") %>
  #     <% group.with_button("Settings") %>
  #     <% group.with_button("Messages") %>
  #   <% end %>
  #
  # === Links
  #
  # Pass +tag: :a+ and +href+ to render links. Mark the current page with
  # +aria: { current: "page" }+:
  #
  #   <%= render Gustwave::ButtonGroup.new(role: nil) do |group| %>
  #     <% group.with_button("Profile", tag: :a, href: "#", aria: { current: "page" }, class: "text-blue-700") %>
  #     <% group.with_button("Settings", tag: :a, href: "#") %>
  #   <% end %>
  #
  # === Icons
  #
  # Add icons with the button's +with_leading_visual_icon+ or +with_trailing_visual_icon+ setters:
  #
  #   <%= render Gustwave::ButtonGroup.new do |group| %>
  #     <% group.with_button("Profile") { |button| button.with_leading_visual_icon(:user_circle) } %>
  #     <% group.with_button("Settings") %>
  #   <% end %>
  #
  # === Outline
  #
  # Pass +outline: true+ to render every button outlined. A button's own +color+ takes precedence:
  #
  #   <%= render Gustwave::ButtonGroup.new(outline: true) do |group| %>
  #     <% group.with_button("Profile") %>
  #     <% group.with_button("Settings", color: :default) %>
  #   <% end %>
  #
  # @see Gustwave::ButtonGroups::Button
  class ButtonGroup < Gustwave::Component
    base "inline-flex rounded-md shadow-xs"

    # Renders every button outlined, unless a button picks its own color
    toggle :outline

    # Adds a button to the group. The group sets its position once all buttons are added.
    #
    # @param text [String, nil] the text of the button. Takes precedence over block content.
    # @param options [Hash] arguments of Gustwave::ButtonGroups::Button, e.g. +tag+, +href+, +color+, +size+. Pass a block to add visuals, e.g. +button.with_leading_visual_icon(:user_circle)+.
    renders_many_extensible :buttons, ->(text = nil, **options) {
      Gustwave::ButtonGroups::Button.new(text, **{ color: button_color }.merge(options))
    }

    # @param outline [Boolean] whether to render every button outlined. A button's own +color+ takes precedence.
    # @param options [Hash] additional HTML attributes for the group element. Its +role+ defaults to +group+; pass +role: nil+ to remove it, e.g. for links.
    def initialize(outline: false, **options)
      select_options(outline:)
      @options = attributes_for({ role: "group" }.merge(options))
    end

    def before_render
      buttons.each_with_index do |button, index|
        button.apply_slot_context(slot: :buttons, group_position: group_position(index))
      end
    end

    def call
      tag.div(**@options) { slots_and_content(*buttons) }
    end

    private

    def button_color
      option_value(:outline) ? :outline : :default
    end

    # :only for a single button, otherwise :first, :middle or :last
    def group_position(index)
      return :only if buttons.size == 1
      return :first if index.zero?
      return :last if index == buttons.size - 1

      :middle
    end
  end
end
