module Gustwave
  class HorizontalLinePreview < ViewComponent::Preview
    # Every shape, one below the other.
    def shapes
      render_with_template(locals: { shapes: Gustwave::HorizontalLine.option_values(:shape).excluding(:none) })
    end

    # Flowbite's default rule between two paragraphs.
    def default
      render_with_template
    end

    # Flowbite's trimmed rule between two paragraphs.
    def trimmed
      render_with_template
    end

    # Flowbite's rule with an icon in the middle.
    def icon
      render_with_template
    end

    # Flowbite's rule with text in the middle.
    def with_text
      render_with_template
    end

    # Flowbite's squared rule above a quote.
    def squared
      render_with_template
    end

    def with_styled_text
      render Gustwave::HorizontalLine.new do |line|
        line.with_visual_text "Section", class: "font-semibold text-gray-900 dark:text-white"
      end
    end
  end
end
