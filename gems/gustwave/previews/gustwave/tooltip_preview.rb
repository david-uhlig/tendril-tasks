module Gustwave
  class TooltipPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/tooltip/default
    #
    # Spread +trigger_options+ into the triggering element.
    def default(placement: :top, trigger: :hover, scheme: :dark, arrow: true)
      render_with_template(locals: { placement:, trigger:, scheme:, arrow: })
    end

    # http://localhost:3030/rails/view_components/gustwave/tooltip/detached
    #
    # The tooltip doesn't have to follow its trigger. The arrow of the light
    # scheme is bordered nonetheless.
    def detached(placement: :top)
      render_with_template(locals: { placement: })
    end
  end
end
