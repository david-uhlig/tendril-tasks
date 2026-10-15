module Gustwave
  class ButtonPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/button/playground?theme=gradient_duotone&scheme=purple_to_pink
    def playground(text: "Button", theme: :default, scheme: nil, size: nil)
      render Gustwave::Button.new(text, theme:, scheme:, size:)
    end

    # Every theme with each of its schemes. Aliases like :outline are skipped.
    def themes
      themes = Gustwave::Button.themes
                               .uniq { |_name, klass| klass }
                               .to_h { |name, klass| [ name, klass.variant_values(:scheme).excluding(:base, :none) ] }
      render_with_template(locals: { themes: })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Buttons::Base.variant_values(:size).excluding(:none) })
    end

    def pill
      render Gustwave::Button.new("Pill", pill: true)
    end

    def with_icons
      render_with_template
    end

    def with_indicator
      render Gustwave::Button.new("Messages") do |button|
        button.trailing_indicator "3"
      end
    end

    def as_link
      render Gustwave::Button.new("Link", tag: :a, href: "#")
    end

    def disabled
      render Gustwave::Button.new("Disabled", disabled: true)
    end
  end
end
