module Gustwave
  class IndicatorPreview < ViewComponent::Preview
    # Flowbite's default example: one dot per color. Flowbite's palette has no white dot.
    def colors
      render_with_template(locals: { colors: Gustwave::Indicator.option_values(:color).excluding(:none, :white) })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Indicator.option_values(:size).excluding(:none, :auto) })
    end

    def pulse
      render Gustwave::Indicator.new(color: :green, size: :md, pulse: true)
    end

    # Flowbite's legend example.
    def legend
      render_with_template
    end

    # Flowbite's count example: a count on the corner of a button.
    def count
      render_with_template
    end

    # Flowbite's status example: a presence dot on the corner of an avatar.
    def status
      render_with_template
    end

    # Flowbite's badge example: a dot inside a badge. Its 8px dot has no size of its own, so it sets one.
    def badge
      render_with_template
    end

    # Flowbite's loading example: a pulsing pill while a card loads.
    def loading
      render_with_template
    end

    # Flowbite's spinner example: a spinner while a card loads.
    def spinner
      render_with_template
    end

    # Flowbite's position example: an indicator at each of the nine positions.
    def position
      render_with_template
    end

    # The indicator sits on the corner of a +relative+ parent.
    def positioned
      render_with_template
    end
  end
end
