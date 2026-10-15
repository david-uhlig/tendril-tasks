module Gustwave
  class BadgePreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/badge/with_text_block
    def with_text_parameter
      render Gustwave::Badge.new("Default")
    end

    def with_text_block
      render Gustwave::Badge.new do
        "Default"
      end
    end

    def schemes
      render_with_template(locals: { schemes: Gustwave::Badge::SCHEME_OPTIONS })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Badge.variant_values(:size).excluding(:none) })
    end

    def pill
      render Gustwave::Badge.new("Default", pill: true)
    end

    def bordered
      render Gustwave::Badge.new("Default", border: true)
    end

    def outlined
      render Gustwave::Badge.new("Default", outline: true)
    end

    def as_link
      render Gustwave::Badge.new("Default", tag: :a, href: "#")
    end

    def with_icon_and_text
      render Gustwave::Badge.new("2 minutes ago", border: true) do |badge|
        badge.leading_icon :clock
      end
    end

    def with_icon
      render Gustwave::Badge.new(scheme: :red, pill: true, aria: { label: "Verified" }) do |badge|
        badge.leading_icon :badge_check
      end
    end

    def with_indicator
      render Gustwave::Badge.new("Messages", scheme: :dark) do |badge|
        badge.trailing_indicator "4"
      end
    end

    def dismissible
      render Gustwave::Badge.new("Default", scheme: :indigo, id: "badge-dismiss-default") do |badge|
        badge.dismiss_button
      end
    end
  end
end
