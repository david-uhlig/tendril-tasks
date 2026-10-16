module Gustwave
  class IconPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/icon/gallery
    #
    # Every icon Gustwave ships, by theme, with the name to pass to Icon.
    def gallery
      icons = Gustwave::Icon.option_values(:theme).to_h do |theme|
        directory = Gustwave::Engine.root.join("app/assets/images", Gustwave::Icon::ICON_PATH, theme.to_s)
        [ theme, directory.glob("*.svg").map { |file| file.basename(".svg").to_s.tr("-", "_").to_sym }.sort ]
      end
      render_with_template(locals: { icons: })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Icon.option_values(:size).excluding(:none) })
    end

    def stroke_widths
      render_with_template(locals: { stroke_widths: Gustwave::Icon.option_values(:stroke_width).excluding(:none) })
    end

    def colors
      render_with_template
    end
  end
end
