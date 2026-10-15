module Gustwave
  module Containers
    class ResponsiveHorizontalScrollPreview < ViewComponent::Preview
      # http://localhost:3030/rails/view_components/gustwave/containers/responsive_horizontal_scroll/default
      #
      # Scrolls horizontally below the +md+ breakpoint and wraps from there on.
      # Resize the window to see both.
      def default(breakpoint: :md)
        render_with_template(locals: { breakpoint: breakpoint.to_sym })
      end
    end
  end
end
