module Gustwave
  class ButtonPreview < ViewComponent::Preview
    SOCIAL_BUTTONS = [
      { text: "Sign in with Facebook", icon: :facebook, icon_class: "h-[18px] w-[18px]", colors: "text-white bg-[#3b5998] hover:bg-[#3b5998]/90 focus:ring-[#3b5998]/50 dark:focus:ring-[#3b5998]/55" },
      { text: "Sign in with Twitter", icon: :twitter, icon_class: "h-[18px] w-[18px]", colors: "text-white bg-[#1da1f2] hover:bg-[#1da1f2]/90 focus:ring-[#1da1f2]/50 dark:focus:ring-[#1da1f2]/55" },
      { text: "Sign in with Github", icon: :github, icon_class: "h-[18px] w-[18px] -ms-px me-px", colors: "text-white bg-[#24292F] hover:bg-[#24292F]/90 focus:ring-[#24292F]/50 dark:focus:ring-gray-500 dark:hover:bg-[#050708]/30" },
      { text: "Sign in with Google", icon: :google, icon_class: "h-[18px] w-[18px] -ms-px me-px", colors: "text-white bg-[#4285F4] hover:bg-[#4285F4]/90 focus:ring-[#4285F4]/50 dark:focus:ring-[#4285F4]/55" },
      { text: "Sign in with Apple", icon: :apple, icon_class: "h-[22px] w-[22px] -ms-[5px] me-px -my-px", colors: "text-white bg-[#050708] hover:bg-[#050708]/90 focus:ring-[#050708]/50 dark:focus:ring-[#050708]/50 dark:hover:bg-[#050708]/30" }
    ].freeze

    # @param text text
    # @param theme select { choices: [default, default_outline, gradient_monochrome, gradient_monochrome_colored_shadow, gradient_duotone, gradient_duotone_outline, inline] }
    # @param color text "Depends on the theme. Leave blank for its default."
    # @param size select { choices: [xs, sm, md, lg, xl] }
    def playground(text: "Button", theme: :default, color: nil, size: :md)
      render Gustwave::Button.for(theme).new(text, color: color.presence, size:)
    end

    # Every theme with each of its colors. Aliases like :outline are skipped.
    def themes
      themes = Gustwave::Button.themes
                               .uniq { |_name, klass| klass }
                               .to_h { |name, klass| [ name, klass.option_values(:color).excluding(:base, :none) ] }
      render_with_template(locals: { themes: })
    end

    def sizes
      render_with_template(locals: { sizes: Gustwave::Buttons::Base.option_values(:size).excluding(:none) })
    end

    def pill
      render Gustwave::Buttons::Default.new("Pill", pill: true)
    end

    def with_icons
      render_with_template
    end

    def with_indicator
      render Gustwave::Buttons::Default.new("Messages") do |button|
        button.with_trailing_visual_indicator "3"
      end
    end

    def as_link
      render Gustwave::Buttons::Default.new("Link", tag: :a, href: "#")
    end

    def sizes_with_icon
      render_with_template
    end

    def with_icon
      render_with_template
    end

    def disabled
      render Gustwave::Buttons::Default.new("Disabled", disabled: true)
    end

    def social
      render_with_template(locals: { buttons: SOCIAL_BUTTONS })
    end

    def with_label
      render_with_template
    end

    def icon_only
      render_with_template
    end

    def loader
      render_with_template
    end

    def default_colors
      render_with_template(locals: { colors: %i[default alternative dark light green red yellow purple] })
    end

    def pills
      render_with_template(locals: { colors: %i[default alternative dark light green red yellow purple] })
    end

    def outline_colors
      render_with_template(locals: { colors: %i[default dark green red yellow purple] })
    end

    def gradient_monochrome
      render_with_template(locals: { colors: %i[blue green cyan teal lime red pink purple] })
    end

    def gradient_duotone
      render_with_template(locals: { colors: %i[purple_to_blue cyan_to_blue green_to_blue purple_to_pink pink_to_orange teal_to_lime red_to_yellow] })
    end

    def gradient_outline
      render_with_template(locals: { colors: %i[purple_to_blue cyan_to_blue green_to_blue purple_to_pink pink_to_orange teal_to_lime red_to_yellow] })
    end

    def colored_shadows
      render_with_template(locals: { colors: %i[blue green cyan teal lime red pink purple] })
    end
  end
end
