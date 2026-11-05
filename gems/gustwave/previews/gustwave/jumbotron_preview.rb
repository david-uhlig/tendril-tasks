module Gustwave
  class JumbotronPreview < ViewComponent::Preview
    # A centered hero with a heading, a paragraph and two buttons. This is Flowbite's default jumbotron.
    def default
      render_with_template
    end

    # A centered hero over a dark background image, with a taller container for more room.
    def background_image
      render_with_template
    end

    # A hero with the text on the left and a video on the right, from the lg breakpoint up.
    def featured_video
      render_with_template
    end

    # A hero with the text on the left and a sign-in form on the right.
    def authentication_form
      render_with_template
    end

    # A centered hero with a "New" announcement, an email sign-up form and a gradient overlay.
    def gradient_background
      render_with_template
    end

    # A hero with a large card on top and two cards side by side below it.
    def with_cards
      render_with_template
    end
  end
end
