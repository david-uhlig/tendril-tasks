module Gustwave
  class SpinnerPreview < ViewComponent::Preview
    def default
      render Gustwave::Spinner.new
    end

    def colors
      render_with_template(locals: { colors: Gustwave::Spinner.option_values(:color).excluding(:none) })
    end

    def sizes
      render_with_template(locals: { sizes: %i[xs sm md lg xl 2xl] })
    end

    # The spinner centered on a +relative+ parent, e.g. while a card loads.
    def positioned
      render_with_template
    end
  end
end
