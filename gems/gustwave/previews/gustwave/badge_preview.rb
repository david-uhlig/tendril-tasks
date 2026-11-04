module Gustwave
  class BadgePreview < ViewComponent::Preview
    def with_text_parameter
      render Gustwave::Badge.new("Default")
    end

    def with_text_block
      render Gustwave::Badge.new do
        "Default"
      end
    end

    def colors
      render_with_template(locals: { colors: flowbite_colors })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Badge.option_values(:size).excluding(:none) })
    end

    def large
      render_with_template(locals: { colors: flowbite_colors })
    end

    def pill
      render_with_template(locals: { colors: flowbite_colors })
    end

    def bordered
      render_with_template(locals: { colors: flowbite_colors })
    end

    def outlined
      render Gustwave::Badge.new("Default", outline: true)
    end

    def as_link
      render_with_template
    end

    def with_icon_and_text
      render_with_template
    end

    def with_icon
      render_with_template
    end

    def with_indicator
      render Gustwave::Badge.new("Messages", color: :dark) do |badge|
        badge.with_trailing_visual_indicator "4"
      end
    end

    def dismissible
      render_with_template(locals: { colors: flowbite_colors })
    end

    private

    def flowbite_colors
      Gustwave::Badge.option_values(:color).excluding(:none, :base)
    end
  end
end
