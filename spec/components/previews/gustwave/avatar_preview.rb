module Gustwave
  module Previews
    class AvatarPreview < ViewComponent::Preview
      # http://localhost:3030/rails/view_components/gustwave/previews/avatar/with_border
      def with_border(size: :lg)
        render Gustwave::Avatar.new(src: "https://loremflickr.com/300/300", size: size, border: true)
      end
    end
  end
end
