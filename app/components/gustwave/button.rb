# frozen_string_literal: true

module Gustwave
  # Renders a button in the specified theme. Use Button for actions (e.g. in
  # forms). Use links for destinations, or moving from one page to another.
  #
  # === Available Themes
  #
  # This component acts as a delegator to the themed button components. You can
  # view all registered themes by running `Gustwave::Buttons.themes` at
  # *runtime*. By default, Gustwave registers the following themes:
  # - :default
  # - :default_outline == :outline
  # - :gradient_monochrome
  # - :gradient_monochrome_colored_shadow == :colored_shadow
  # - :gradient_duotone
  # - :gradient_duotone_outline
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
  #     theme_for Gustwave::Button
  #
  #     style :scheme,
  #           default: :dark,
  #           states: {
  #             dark: "text-white bg-gray-800",
  #             light: "text-gray-900 bg-white border border-gray-300"
  #           }
  #   end
  #
  # This defines a very simple monochrome button scheme and registers it with
  # Gustwave::Button as :monochrome_button. By default, the style method merges
  # the parents style layer (here :scheme) with the new states. Under the hood
  # it uses Hash#merge. You can now use this theme by calling:
  #
  #   render Gustwave::Button.new("Click me", theme: :monochrome_button)
  #
  class Button < Gustwave::Component
    with_default_theme :default
    delegate_missing_to :themed_button

    DEFAULT_TAG = Gustwave::Buttons::Base::DEFAULT_TAG
    DEFAULT_TYPE = Gustwave::Buttons::Base::DEFAULT_TYPE
    DEFAULT_THEME = :default

    THEME_DEFAULT_SCHEME = nil
    THEME_DEFAULT_SIZE = nil
    THEME_DEFAULT_PILL = nil

    # @param [String, nil] text The text to display on the button. Takes
    #   precedent over the block content.
    # @param [Symbol] tag The HTML tag to render the button as. Available
    #   options depend on the theme. Gustwave::Buttons allow :button and :a
    #   tags, and default to :button.
    # @param [Symbol] type The type of the button. Available options depend on
    #   the theme. Gustwave::Buttons allows :button, :submit, and :reset.
    #   Defaults to :button. Only relevant for +tag+ == :button.
    # @param [Symbol] theme The theme to use for the button. Gustwave defines
    #   :default, :default_outline, :gradient_monochrome,
    #   :gradient_monochrome_colored_shadow, :gradient_duotone, and
    #   :gradient_duotone_outline. See all available themes by running
    #   Gustwave::Buttons.themes at runtime! Defaults to :default.
    # @param [Symbol] scheme One of the theme's appearance options, e.g. :red,
    #   :blue, :green, :purple, etc.
    # @param [Symbol] size One of the theme's size options. Usually :none, :xs,
    #   :sm, :md, :lg, or :xl.
    # @param [Boolean] pill Whether the button should be pill-shaped. Defaults to
    #   false.
    # @param [Hash] options Additional HTML attributes to add to the button,
    #   e.g. :class to overwrite some of the theme's styles.
    def initialize(text = nil,
                   tag: DEFAULT_TAG,
                   type: DEFAULT_TYPE,
                   theme: DEFAULT_THEME,
                   scheme: THEME_DEFAULT_SCHEME,
                   size: THEME_DEFAULT_SIZE,
                   pill: THEME_DEFAULT_PILL,
                   **options)
      @theme = theme.presence || default_theme
      @text = text
      @options = options.symbolize_keys!
      @options[:tag] ||= tag
      @options[:type] ||= type
      @options[:scheme] ||= scheme
      @options[:size] ||= size
      @options[:pill] ||= pill
      @options.compact!
    end

    def call
      render themed_button do
        content
      end
    end

    private

    def themed_button
      @themed_button ||= themed_component(@theme).new(@text, **@options)
    end
  end
end
