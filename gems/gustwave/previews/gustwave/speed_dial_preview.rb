module Gustwave
  class SpeedDialPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/speed_dial/default
    #
    # The menu opens on hover, and the labels are shown as tooltips.
    def default(position: :bottom_right, direction: :up, trigger_event: :hover, shape: :round, label_display: :tooltip)
      render_with_template(locals: { position:, direction:, trigger_event:, shape:, label_display: })
    end

    # http://localhost:3030/rails/view_components/gustwave/speed_dial/square
    def square
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/speed_dial/text_inside
    def text_inside
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/speed_dial/text_outside
    def text_outside
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/speed_dial/horizontal
    def horizontal
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/speed_dial/click
    def click
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/speed_dial/positions
    #
    # One speed dial in each corner of the viewport.
    def positions
      render_with_template
    end
  end
end
