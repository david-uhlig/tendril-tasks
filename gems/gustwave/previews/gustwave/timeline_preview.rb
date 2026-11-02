module Gustwave
  class TimelinePreview < ViewComponent::Preview
    def default
      render_with_template
    end

    def with_icons
      render_with_template
    end

    def horizontal
      render_with_template
    end

    # A composition: image markers, with a Gustwave::Card as block content.
    def activity_log
      render_with_template
    end
  end
end
