module Gustwave
  class TimelinePreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/timeline/default
    def default
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/timeline/with_icons
    def with_icons
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/timeline/horizontal
    def horizontal
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/timeline/activity_log
    #
    # A composition: image markers, with a Gustwave::Card as block content.
    def activity_log
      render_with_template
    end
  end
end
