module Gustwave
  class TooltipPreview < ViewComponent::Preview
    # Spread +trigger_options+ into the triggering element.
    # @param placement select { choices: [auto, auto-start, auto-end, top, top-start, top-end, bottom, bottom-start, bottom-end, right, right-start, right-end, left, left-start, left-end] }
    # @param trigger select { choices: [hover, click] }
    # @param color select { choices: [dark, light] }
    # @param arrow toggle
    def default(placement: :top, trigger: :hover, color: :dark, arrow: true)
      render_with_template(locals: { placement:, trigger:, color:, arrow: })
    end

    # The tooltip doesn't have to follow its trigger. The arrow of a light
    # tooltip is bordered nonetheless.
    # @param placement select { choices: [auto, auto-start, auto-end, top, top-start, top-end, bottom, bottom-start, bottom-end, right, right-start, right-end, left, left-start, left-end] }
    def detached(placement: :top)
      render_with_template(locals: { placement: })
    end
  end
end
