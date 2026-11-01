module Gustwave
  class DeviceMockupPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/device_mockup/default
    def default
      render_with_template
    end

    # An iPhone, with a light and a dark screenshot composed from two images.
    def iphone
      render_with_template
    end

    # A Google Pixel.
    def android
      render_with_template
    end

    # A tablet, which grows from the md breakpoint.
    def tablet
      render_with_template
    end

    # A laptop with its keyboard.
    def laptop
      render_with_template
    end

    # A desktop with its chin and stand.
    def desktop
      render_with_template
    end

    # A smartwatch with its straps and crown.
    def smartwatch
      render_with_template
    end

    # The dark and light frames of a phone and a laptop, side by side.
    def colors
      render_with_template
    end
  end
end
