module Gustwave
  module Containers
    class ResponsiveHorizontalScrollPreview < ViewComponent::Preview
      # Scrolls horizontally below the +md+ breakpoint and wraps from there on.
      # Resize the window to see both.
      def default(breakpoint: :md)
        render_with_template(locals: { breakpoint: breakpoint.to_sym })
      end
    end
  end
end
