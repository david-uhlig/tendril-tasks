module Gustwave
  class BannerPreview < ViewComponent::Preview
    def default(position: :top)
      render_with_template(locals: { position: position.to_sym })
    end

    def bottom
      render_with_template(template: "gustwave/banner_preview/default", locals: { position: :bottom })
    end

    # Flowbite's marketing CTA
    def marketing
      render_with_template
    end

    def newsletter
      render_with_template
    end

    def informational
      render_with_template
    end
  end
end
