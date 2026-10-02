module Gustwave
  class AvatarPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/avatar/with_border
    def with_border(size: :lg)
      render Gustwave::Avatar.new(src: "/icon.png", size: size, border: true)
    end
  end
end
