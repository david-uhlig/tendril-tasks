module Gustwave
  class ModalPreview < ViewComponent::Preview
    # @param size select { choices: [sm, md, lg, xl] }
    # @param placement select { choices: [top-left, top-center, top-right, center-left, center, center-right, bottom-left, bottom-center, bottom-right] }
    # @param backdrop select { choices: [dynamic, static] }
    def default(size: :md, placement: :center, backdrop: :dynamic)
      render_with_template(locals: { size:, placement:, backdrop: })
    end

    def static_backdrop
      render_with_template
    end

    def not_dismissible
      render_with_template
    end

    # The header's close button customized with +with_close_button+.
    def custom_close_button
      render_with_template
    end

    def popup
      render_with_template
    end

    def with_form
      render_with_template
    end

    def with_timeline
      render_with_template
    end

    def crypto_wallet
      render_with_template
    end

    def sizes
      render_with_template
    end

    def placement
      render_with_template
    end
  end
end
