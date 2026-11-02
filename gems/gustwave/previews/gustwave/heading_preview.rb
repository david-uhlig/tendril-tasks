module Gustwave
  class HeadingPreview < ViewComponent::Preview
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

    # Flowbite's default heading: a hero with a paragraph and a button.
    def default
      render_with_template
    end

    # A second-level heading with paragraphs and a link.
    def second_level
      render_with_template
    end

    # Highlight part of a heading by coloring it.
    def highlighted
      render_with_template
    end

    # Mark part of a heading with a background.
    def mark
      render_with_template
    end

    # A gradient across part of a heading.
    def gradient
      render_with_template
    end

    # Underline part of a heading.
    def underline
      render_with_template
    end

    # A badge next to the heading.
    def badge
      render_with_template
    end

    # Smaller secondary text next to the heading.
    def secondary
      render_with_template
    end

    def heading_one
      render Gustwave::Heading.new("Heading 1", tag: :h1)
    end

    def heading_two
      render Gustwave::Heading.new("Heading 2", tag: :h2)
    end

    def heading_three
      render Gustwave::Heading.new("Heading 3", tag: :h3)
    end

    def heading_four
      render Gustwave::Heading.new("Heading 4", tag: :h4)
    end

    def heading_five
      render Gustwave::Heading.new("Heading 5", tag: :h5)
    end

    # Heading has no size this small, so the class sets the font size.
    def heading_six
      render Gustwave::Heading.new("Heading 6", tag: :h6, class: "text-lg")
    end
  end
end
