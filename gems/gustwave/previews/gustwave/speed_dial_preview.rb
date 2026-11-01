module Gustwave
  class SpeedDialPreview < ViewComponent::Preview
    # The menu opens on hover, and the labels are shown as tooltips.
    def default(position: :bottom_right, direction: :up, trigger_event: :hover, shape: :round, label_display: :tooltip)
      render_with_template(locals: { position:, direction:, trigger_event:, shape:, label_display: })
    end

    def square
      render_with_template
    end

    def text_inside
      render_with_template
    end

    def text_outside
      render_with_template
    end

    def horizontal
      render_with_template
    end

    def click
      render_with_template
    end

    # One speed dial in each corner of the viewport.
    def positions
      render_with_template
    end
  end
end
