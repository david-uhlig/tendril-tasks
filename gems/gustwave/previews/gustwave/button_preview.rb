module Gustwave
  class ButtonPreview < ViewComponent::Preview
    # @param text text
    # @param theme select { choices: [default, default_outline, gradient_monochrome, gradient_monochrome_colored_shadow, gradient_duotone, gradient_duotone_outline, inline] }
    # @param color text "Depends on the theme. Leave blank for its default."
    # @param size select { choices: [xs, sm, md, lg, xl] }
    def playground(text: "Button", theme: :default, color: nil, size: :md)
      render Gustwave::Button.for(theme).new(text, color: color.presence, size:)
    end

    # Every theme with each of its colors. Aliases like :outline are skipped.
    def themes
      themes = Gustwave::Button.themes
                               .uniq { |_name, klass| klass }
                               .to_h { |name, klass| [ name, klass.option_values(:color).excluding(:base, :none) ] }
      render_with_template(locals: { themes: })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Buttons::Base.option_values(:size).excluding(:none) })
    end

    def pill
      render Gustwave::Buttons::Default.new("Pill", pill: true)
    end

    def with_icons
      render_with_template
    end

    def with_indicator
      render Gustwave::Buttons::Default.new("Messages") do |button|
        button.with_trailing_visual_indicator "3"
      end
    end

    def as_link
      render Gustwave::Buttons::Default.new("Link", tag: :a, href: "#")
    end

    def disabled
      render Gustwave::Buttons::Default.new("Disabled", disabled: true)
    end
  end
end
