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

    # Justified text, spread to fill each line.
    def align_justify
      render_with_template
    end

    # A link that triggers a popover.
    def popover
      render_with_template
    end

    # Paragraphs stacked in one column.
    def one_column
      render_with_template
    end

    # Two even columns between full-width paragraphs.
    def two_columns
      render_with_template
    end

    # Three even columns between full-width paragraphs.
    def three_columns
      render_with_template
    end

    # A wide and a narrow column between full-width paragraphs.
    def two_columns_uneven
      render_with_template
    end

    # Text in each font size, from extra small to 9xl.
    def font_size
      render_with_template
    end

    # Text in each font weight, from thin to black.
    def font_weight
      render_with_template
    end

    # Text in different colors.
    def text_color
      render_with_template
    end

    # Text with each letter spacing, from tighter to widest.
    def letter_spacing
      render_with_template
    end

    # An old price struck through next to the new one.
    def line_through
      render_with_template
    end

    # A word in uppercase inside a sentence.
    def uppercase
      render_with_template
    end

    # A word in italics inside a sentence.
    def font_style_italic
      render_with_template
    end

    # Text in the normal, non-italic font style.
    def font_style_normal
      render_with_template
    end

    # Large text with normal line height.
    def line_height_normal
      render_with_template
    end

    # Large text with relaxed line height.
    def line_height_relaxed
      render_with_template
    end

    # Large text with loose line height.
    def line_height_loose
      render_with_template
    end

    # Text whose line breaks collapse into spaces.
    def whitespace_normal
      render_with_template
    end

    # Text that stays on one line, even past the edge.
    def whitespace_nowrap
      render_with_template
    end

    # Text that keeps the line breaks of its source.
    def whitespace_pre_line
      render_with_template
    end

    # Text in one color at decreasing opacity.
    def opacity
      render_with_template
    end
  end
end
