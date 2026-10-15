module Gustwave
  class HeadingPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/heading/levels
    def levels
      render_with_template
    end

    # Smaller on mobile, full size from the +md+ breakpoint up.
    def responsive
      render Gustwave::Heading.new("Responsive heading", tag: :h1, responsive: true)
    end

    # The tag and the look are independent, e.g. an +h2+ that looks like an +h4+.
    def tag_and_scheme
      render Gustwave::Heading.new("An h2 styled as level 4", tag: :h2, scheme: :level4)
    end
  end
end
