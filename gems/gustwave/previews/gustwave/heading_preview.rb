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
    def tag_and_size
      render Gustwave::Heading.new("An h2 sized as md", tag: :h2, size: :md)
    end
  end
end
