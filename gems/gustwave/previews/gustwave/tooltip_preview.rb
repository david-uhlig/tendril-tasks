module Gustwave
  class TooltipPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/tooltip/default
    #
    # Spread +trigger_options+ into the triggering element.
    def default(placement: :top, trigger: :hover, color: :dark, arrow: true)
      render_with_template(locals: { placement:, trigger:, color:, arrow: })
    end

    # http://localhost:3030/rails/view_components/gustwave/tooltip/detached
    #
    # The tooltip doesn't have to follow its trigger. The arrow of a light
    # tooltip is bordered nonetheless.
    def detached(placement: :top)
      render_with_template(locals: { placement: })
    end
  end
end
