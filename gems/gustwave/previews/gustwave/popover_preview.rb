module Gustwave
  class PopoverPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/popover/default
    #
    # Spread +trigger_options+ into the triggering element.
    def default(placement: :top, trigger: :hover)
      render_with_template(locals: { placement:, trigger: })
    end
  end
end
