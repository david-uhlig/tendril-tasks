module Gustwave
  class DismissButtonPreview < ViewComponent::Preview
    # Removes the element whose id matches the target.
    def default
      render_with_template
    end

    # A leading visual set through the slot replaces the default icon.
    def custom_icon
      render_with_template
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Buttons::Inline.option_values(:size).excluding(:none) })
    end
  end
end
