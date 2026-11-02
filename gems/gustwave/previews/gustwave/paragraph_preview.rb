module Gustwave
  class ParagraphPreview < ViewComponent::Preview
    # Two paragraphs of body text.
    def default
      render_with_template
    end

    # A larger first paragraph that introduces the text below it.
    def leading
      render_with_template
    end

    # A large first letter and an uppercase first line, using Tailwind's first-letter and first-line variants.
    def first_letter
      render_with_template
    end

    # A link inside a paragraph.
    def link
      render_with_template
    end

    # Bold text inside a paragraph.
    def bold
      render_with_template
    end

    # Underlined text inside a paragraph.
    def underline
      render_with_template
    end

    # Italic text inside a paragraph.
    def italic
      render_with_template
    end

    # Left-aligned text, mirrored for right-to-left text.
    def align_left
      render_with_template
    end

    # Centered text.
    def align_center
      render_with_template
    end

    # Right-aligned text, mirrored for right-to-left text.
    def align_right
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
