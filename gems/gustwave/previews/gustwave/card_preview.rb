module Gustwave
  class CardPreview < ViewComponent::Preview
    def default
      render_with_template
    end

    # The whole card as a link, with a hover style.
    def link
      render_with_template
    end

    # A card with a paragraph and a button that links on.
    def with_button
      render_with_template
    end

    # A card with an image above the body.
    def image
      render_with_template
    end

    # A card with the image beside the body from the md breakpoint up.
    def horizontal
      render_with_template
    end

    # Cards in a grid: a user profile, a call to action, a pricing plan and a list.
    def compositions
      render_with_template
    end
  end
end
