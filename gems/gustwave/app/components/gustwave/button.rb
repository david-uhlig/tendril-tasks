# frozen_string_literal: true

module Gustwave
  # Renders a button in the specified theme. Use Button for actions (e.g. in
  # forms). Use links for destinations, or moving from one page to another.
  #
  # === Available Themes
  #
  # This component acts as a delegator to the themed button components. You can
  # view all registered themes by running `Gustwave::Button.themes`. By default,
  # Gustwave registers the following themes:
  # - :default
  # - :default_outline == :outline
  # - :gradient_monochrome
  # - :gradient_monochrome_colored_shadow == :colored_shadow
  # - :gradient_duotone
  # - :gradient_duotone_outline
  # - :inline
  #
  # === Picking a Different Default Theme
  #
  # Many applications will only need to use one of the themes. Use composition
  # to improve the readability of your code. For example, if you want to use the
  # :gradient_duotone theme, all you need to do is:
  #
  #   class Ui::Button < Gustwave::Component
  #     def initialize(text = nil, theme: :gradient_duotone, **options)
  #       @text = text
  #       @theme = theme
  #       @options = options
  #     end
  #
  #     def call
  #       render Gustwave::Button.new(theme: @theme, **@options) do
  #         @text || content
  #       end
  #     end
  #   end
  #
  # === Building a Custom Theme
  #
  # Building a custom theme is really easy to do. Style definitions in Gustwave
  # are inherited from their parent components. So, you only have to define the
  # styles that are different and can inherit everything else from
  # Gustwave::Buttons::Base. For example:
  #
  #   class Ui::MonochromeButton < Gustwave::Buttons::Base
  #     extend_variant :color, default: :dark, values: {
  #       dark: "text-white bg-gray-800",
  #       light: "text-gray-900 bg-white border border-gray-300"
  #     }
  #   end
  #
  # This defines a very simple monochrome button color. +extend_variant+
  # adds the new values to the inherited +:color+ variant and keeps the
  # others, e.g. +:none+ and +:base+. See Gustwave::Styling for the other
  # declarations. Register it with Gustwave::Button in
  # +to_prepare+, so that it is registered again when Gustwave::Button is
  # reloaded in development:
  #
  #   # config/initializers/gustwave.rb
  #   Rails.application.config.to_prepare do
  #     Gustwave::Button.register_theme :monochrome_button, "Ui::MonochromeButton"
  #   end
  #
  # You can now use this theme by calling:
  #
  #   render Gustwave::Button.new("Click me", theme: :monochrome_button)
  #
  class Button
    include Gustwave::Themeable

    register_theme :default, "Gustwave::Buttons::Default"
    register_theme :default_outline, "Gustwave::Buttons::DefaultOutline"
    register_theme :outline, "Gustwave::Buttons::DefaultOutline"
    register_theme :gradient_monochrome, "Gustwave::Buttons::GradientMonochrome"
    register_theme :gradient_monochrome_colored_shadow, "Gustwave::Buttons::GradientMonochromeColoredShadow"
    register_theme :colored_shadow, "Gustwave::Buttons::GradientMonochromeColoredShadow"
    register_theme :gradient_duotone, "Gustwave::Buttons::GradientDuotone"
    register_theme :gradient_duotone_outline, "Gustwave::Buttons::GradientDuotoneOutline"
    register_theme :inline, "Gustwave::Buttons::Inline"
    with_default_theme :default

    # Returns the themed button class for +theme+.
    #
    # @param theme [Symbol, nil] The theme to use. Uses the default theme when +nil+ or Gustwave::Options::DEFAULT.
    # @return [Class<Gustwave::Buttons::Base>] The themed button class.
    def self.for(theme)
      themed_component(theme)
    end

    private_class_method :new
  end
end
