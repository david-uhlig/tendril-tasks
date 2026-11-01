module Gustwave
  class DrawerPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/drawer/default
    #
    # Spread +trigger_options+ into the triggering element.
    def default(placement: :left, backdrop: true, body_scrolling: false)
      render_with_template(locals: { placement:, backdrop:, body_scrolling: })
    end

    # A bottom drawer that peeks out by its edge offset; its handle toggles it.
    def swipeable_edge
      render_with_template
    end

    # Toggle, show and hide buttons on one drawer.
    def multiple_triggers
      render_with_template
    end
  end
end
