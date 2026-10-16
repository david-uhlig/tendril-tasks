module Gustwave
  class IndicatorPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/indicator/schemes
    def schemes
      render_with_template(locals: { schemes: Gustwave::Indicator.option_values(:scheme).excluding(:none) })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Indicator.option_values(:size).excluding(:none, :auto) })
    end

    def pulse
      render Gustwave::Indicator.new(scheme: :green, size: :md, pulse: true)
    end

    def with_text
      render Gustwave::Indicator.new("12", scheme: :red, size: :lg)
    end

    def with_legend
      render Gustwave::Indicator.new(scheme: :green) do |indicator|
        indicator.legend "Online"
      end
    end

    # The indicator sits on the corner of a +relative+ parent.
    def positioned
      render_with_template
    end
  end
end
