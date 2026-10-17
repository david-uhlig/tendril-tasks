# frozen_string_literal: true

module Gustwave
  # Looks up the button class for a theme. Gustwave::Button doesn't render
  # anything itself: +for+ returns the themed button class, which you instantiate
  # to render a button. Use the button class directly when the theme is fixed
  # in code, and +for+ when the theme comes from data or options.
  #
  # === Available Themes
  #
  # View all registered themes by running `Gustwave::Button.themes`. By default,
  # Gustwave registers the following themes:
  # - :default
  # - :default_outline == :outline
  # - :gradient_monochrome
  # - :gradient_monochrome_colored_shadow == :colored_shadow
  # - :gradient_duotone
  # - :gradient_duotone_outline
  # - :inline
  #
  # === Using a Fixed Theme
  #
  # When the theme is known in code, instantiate its class directly. Your IDE can
  # navigate to it, and stack traces stay shallow:
  #
  #   <%= render Gustwave::Buttons::GradientDuotone.new("Sign in") %>
  #
  # Use composition to give the theme a name in your application. For example,
  # to use the :gradient_duotone theme everywhere, all you need to do is:
  #
  #   class Ui::Button < Gustwave::Component
  #     def initialize(text = nil, **options)
  #       @text = text
  #       @options = options
  #     end
  #
  #     def call
  #       render Gustwave::Buttons::GradientDuotone.new(**@options) do
  #         @text || content
  #       end
  #     end
  #   end
  #
  # === Choosing a Theme from Data
  #
  # When the theme comes from data or options, look up its class with +for+ and
  # pass the remaining options to it:
  #
  #   <%= render Gustwave::Button.for(@options[:theme]).new("Click me", **@options.except(:theme)) %>
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
  #   render Gustwave::Button.for(:monochrome_button).new("Click me")
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
