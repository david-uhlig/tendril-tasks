module Gustwave
  class HorizontalLinePreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/horizontal_line/shapes
    def shapes
      render_with_template(locals: { shapes: Gustwave::HorizontalLine.option_values(:shape).excluding(:none) })
    end

    def with_text
      render Gustwave::HorizontalLine.new.with_content("or")
    end

    def with_styled_text
      render Gustwave::HorizontalLine.new do |line|
        line.with_visual_text "Section", class: "font-semibold text-gray-900 dark:text-white"
      end
    end
  end
end
