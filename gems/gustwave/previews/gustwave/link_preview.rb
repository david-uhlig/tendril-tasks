module Gustwave
  class LinkPreview < ViewComponent::Preview
    def default
      render_with_template
    end

    # A link in running text, underlined until hovered.
    def paragraph
      render_with_template
    end

    # An icon composed in the block, mirrored for right-to-left text.
    def icon
      render_with_template
    end

    # The none color inherits the surrounding text style.
    def none_color
      render_with_template
    end
  end
end
