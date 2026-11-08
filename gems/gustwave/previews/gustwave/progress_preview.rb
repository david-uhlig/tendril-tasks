module Gustwave
  class ProgressPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/progress/default
    def default
      render_with_template
    end

    # Small to extra large, each with a text label above.
    def sizes
      render_with_template
    end

    # A label inside the fill, which sets the bar's height.
    def label_inside
      render_with_template
    end

    # A label outside the bar, by composition.
    def label_outside
      render_with_template
    end

    # All colours, each with a text label above.
    def colors
      render_with_template
    end
  end
end
