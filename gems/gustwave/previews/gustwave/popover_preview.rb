module Gustwave
  class PopoverPreview < ViewComponent::Preview
    # Spread +trigger_options+ into the triggering element.
    # @param placement select { choices: [auto, auto-start, auto-end, top, top-start, top-end, bottom, bottom-start, bottom-end, right, right-start, right-end, left, left-start, left-end] }
    # @param trigger select { choices: [hover, click] }
    def default(placement: :top, trigger: :hover)
      render_with_template(locals: { placement:, trigger: })
    end
  end
end
