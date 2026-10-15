module Gustwave
  class HorizontalLinePreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/horizontal_line/schemes
    def schemes
      render_with_template(locals: { schemes: Gustwave::HorizontalLine.variant_values(:scheme).excluding(:none) })
    end

    def with_text
      render Gustwave::HorizontalLine.new.with_content("or")
    end

    def with_styled_text
      render Gustwave::HorizontalLine.new do |line|
        line.text "Section", class: "font-semibold text-gray-900 dark:text-white"
      end
    end
  end
end
