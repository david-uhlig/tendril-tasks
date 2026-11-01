module Gustwave
  class TooltipPreview < ViewComponent::Preview
    # Spread +trigger_options+ into the triggering element.
    def default(placement: :top, trigger: :hover, color: :dark, arrow: true)
      render_with_template(locals: { placement:, trigger:, color:, arrow: })
    end

    # The tooltip doesn't have to follow its trigger. The arrow of a light
    # tooltip is bordered nonetheless.
    def detached(placement: :top)
      render_with_template(locals: { placement: })
    end
  end
end
