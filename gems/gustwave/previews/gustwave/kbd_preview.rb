module Gustwave
  class KbdPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/kbd/default
    def default
      render_with_template
    end

    # Keys inside a paragraph of text.
    def inside_text
      render_with_template
    end

    # Keys in the first column of a table.
    def inside_table
      render_with_template
    end

    # Arrow keys made of icons with screen reader labels.
    def arrow_keys
      render_with_template
    end

    # Function keys F1 to F12.
    def function_keys
      render_with_template
    end
  end
end
