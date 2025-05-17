# frozen_string_literal: true

module Gustwave
  # Provides consistent style definitions for Positionable components
  #
  # Position the Positionable component on the edges of an enclosing +relative+
  # container.
  #
  # You must handle the positioning yourself, e.g., how the component receives
  # the position argument and how it applies the styles. In most cases the
  # Positionable component will be rendered inside another component or an
  # HTML container element. The surrounding element must have the +relative+
  # Tailwind class.
  #
  # === Basic Usage
  #
  #   # app/components/ui/positionable_example.rb
  #   class Ui::PositionableExample < Gustwave::Component
  #     include Gustwave::Positionable
  #
  #     def initialize(position: :none)
  #       @position = position
  #     end
  #
  #     def call
  #       tag.span "Example", class: styles(position: @position)
  #     end
  #   end
  #
  #   # app/views/ui/positionable_example/index.html.erb
  #   <div class="relative">
  #     <%= render Ui::PositionableExample.new(position: :top_left) %>
  #   </div>
  #
  # @see Gustwave::Indicator as an example implementation
  module Positionable
    extend ActiveSupport::Concern

    included do
      style :position,
            default: :none,
            states: {
              none: "",
              top_left: "absolute -translate-y-1/2 -translate-x-1/2 right-auto top-0 left-0",
              # alias for top_center
              top: "absolute -translate-y-1/2 translate-x-1/2 right-1/2",
              top_center: "absolute -translate-y-1/2 translate-x-1/2 right-1/2",
              top_right: "absolute -translate-y-1/2 translate-x-1/2 left-auto top-0 right-0",
              middle_left: "absolute -translate-y-1/2 -translate-x-1/2 right-auto left-0 top-2/4",
              # aliases for middle_center
              center: "absolute -translate-y-1/2 -translate-x-1/2 top-2/4 left-1/2",
              middle: "absolute -translate-y-1/2 -translate-x-1/2 top-2/4 left-1/2",
              middle_center: "absolute -translate-y-1/2 -translate-x-1/2 top-2/4 left-1/2",
              middle_right: "absolute -translate-y-1/2 translate-x-1/2 left-auto right-0 top-2/4",
              bottom_left: "absolute translate-y-1/2 -translate-x-1/2 right-auto bottom-0 left-0",
              # alias for bottom_center
              bottom: "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2",
              bottom_center: "absolute translate-y-1/2 translate-x-1/2 bottom-0 right-1/2",
              bottom_right: "absolute translate-y-1/2 translate-x-1/2 left-auto bottom-0 right-0"
            }
    end
  end
end
