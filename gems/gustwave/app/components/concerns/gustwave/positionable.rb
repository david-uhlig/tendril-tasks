# frozen_string_literal: true

module Gustwave
  # Provides consistent style definitions for Positionable components
  #
  # Position the Positionable component on the edges of an enclosing +relative+
  # container. The component is centered on the chosen edge or corner, i.e.
  # half of it sticks out of the container, like a notification dot on an
  # avatar.
  #
  # Including the concern declares the +position+ variant. Each position
  # combines a vertical anchor (+top+, +middle+, +bottom+) with a horizontal
  # anchor (+left+, +center+, +right+), e.g. +:top_left+ or +:middle_center+.
  # +:top+, +:middle+, +:center+, and +:bottom+ are aliases for the centered
  # positions. +:none+ (the default) adds no classes.
  #
  # You must handle the positioning yourself, e.g., how the component receives
  # the position argument. In most cases the Positionable component will be
  # rendered inside another component or an HTML container element. The
  # surrounding element must have the +relative+ Tailwind class.
  #
  # === Basic Usage
  #
  #   # app/components/ui/positionable_example.rb
  #   class Ui::PositionableExample < Gustwave::Component
  #     include Gustwave::Positionable
  #
  #     def initialize(position: DEFAULT)
  #       style_with(position:)
  #     end
  #
  #     def call
  #       tag.span "Example", class: classes
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
    include Gustwave::Styling

    VERTICAL = {
      top: "top-0 -translate-y-1/2",
      middle: "top-1/2 -translate-y-1/2",
      bottom: "bottom-0 translate-y-1/2"
    }.freeze

    HORIZONTAL = {
      left: "left-0 -translate-x-1/2",
      center: "left-1/2 -translate-x-1/2",
      right: "right-0 translate-x-1/2"
    }.freeze

    ALIASES = {
      top: :top_center,
      middle: :middle_center,
      center: :middle_center,
      bottom: :bottom_center
    }.freeze

    POSITIONS = VERTICAL.keys.product(HORIZONTAL.keys)
                        .to_h { |vertical, horizontal| [ :"#{vertical}_#{horizontal}", "absolute #{VERTICAL[vertical]} #{HORIZONTAL[horizontal]}" ] }
                        .then { |positions| positions.merge(ALIASES.transform_values(&positions)) }
                        .freeze

    included do
      variant :position, default: :none, values: POSITIONS
    end
  end
end
