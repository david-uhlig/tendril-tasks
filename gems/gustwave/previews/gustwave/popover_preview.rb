module Gustwave
  class PopoverPreview < ViewComponent::Preview
    # Spread +trigger_options+ into the triggering element.
    def default(placement: :top, trigger: :hover)
      render_with_template(locals: { placement:, trigger: })
    end
  end
end
