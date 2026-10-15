module Gustwave
  class DismissButtonPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/dismiss_button/default
    #
    # Removes the element whose id matches the target.
    def default
      render_with_template
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::DismissButton.variant_values(:size).excluding(:none) })
    end
  end
end
