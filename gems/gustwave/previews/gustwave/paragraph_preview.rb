module Gustwave
  class ParagraphPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/paragraph/default
    def default
      render_with_template
    end

    # Left, center and right, mirrored for right-to-left text.
    def alignment
      render_with_template
    end

    # Links, bold, underlined and italic text inside a paragraph.
    def inline_elements
      render_with_template
    end

    # A link that triggers a popover.
    def popover
      render_with_template
    end

    # Paragraphs in a grid, between full-width paragraphs.
    def layouts
      render_with_template
    end
  end
end
