module Gustwave
  class CardPreview < ViewComponent::Preview
    def default
      render_with_template
    end

    # The whole card as a link, with a hover style. This is Flowbite's default card.
    def link
      render_with_template
    end

    # A card with a paragraph and a button that links on.
    def with_button
      render_with_template
    end

    # A card with an icon, a paragraph and a text link.
    def with_link
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

    # A profile with a menu, a picture and two buttons.
    def user_profile
      render_with_template
    end

    # A full-width card with centered text and two download buttons.
    def call_to_action
      render_with_template
    end

    # A pricing plan with a list of what is and isn't included.
    def pricing
      render_with_template
    end

    # A list of customers with a link to all of them.
    def list
      render_with_template
    end

    # Four quotes in a grid, each with who said it.
    def testimonial
      render_with_template
    end

    # A list of wallets to connect, each as a link.
    def crypto
      render_with_template
    end

    # Tabs along the top of the card.
    def nav_tabs
      render_with_template
    end

    # Tabs that share the full width of the card.
    def full_width_tabs
      render_with_template
    end

    # A product with its image, name, a rating with a score badge, price and an add to cart button.
    def ecommerce
      render_with_template
    end
  end
end
