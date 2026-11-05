module Gustwave
  class FooterPreview < ViewComponent::Preview
    # A copyright notice and a row of links, in a rounded footer that floats inside the page.
    def default
      render_with_template
    end

    # The brand, a row of links and the copyright notice on a second row, separated by a line.
    def with_logo
      render_with_template
    end

    # A brand, three groups of links and social media icons below a line.
    def social_media
      render_with_template
    end

    # Four groups of links across the page, with a grey bar holding the copyright notice and social icons.
    def sitemap
      render_with_template
    end

    # A footer fixed to the bottom of the viewport. The page content above it needs bottom padding.
    def sticky
      render_with_template
    end
  end
end
