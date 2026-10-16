module Gustwave
  class AvatarPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/avatar/with_border
    def with_border(size: :lg)
      render Gustwave::Avatar.new(src: "/icon.png", size: size, border: true)
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Avatar.option_values(:size).excluding(:none, :original) })
    end

    def square
      render Gustwave::Avatar.new(src: "/icon.png", scheme: :square, size: :lg)
    end

    # Placeholder and initials, for users without a picture
    def placeholder_and_text
      render_with_template
    end

    def group
      render_with_template
    end
  end
end
