# frozen_string_literal: true

module Gustwave
  # Use Themeable to access interchangeable, themed components through a
  # centralized component.
  #
  # This is a specialization of the Strategy pattern where the +subject+ class
  # delegates to one of its registered +theme+ classes.
  #
  # The subject declares its themes by class name. Class names are resolved
  # when a theme is requested, so themes are loaded by the autoloader on
  # demand and survive code reloading.
  #
  # On the subject class:
  # - Use +register_theme+ to register a theme.
  # - Use +with_default_theme+ to set the default theme. (Optional)
  # - Use +themed_component+ to access the theme class.
  #
  # === Benefits
  #
  # This can lead to much cleaner frontend code, e.g. instead of calling
  #   <%= render Gustwave::Buttons::GradientDuotone.new %>
  #   <%= render Ui::Buttons::Funky.new %>
  # you can access all themes through a centralized component
  #   <%= render Gustwave::Button.new(theme: :gradient_duotone) %>
  #   <%= render Gustwave::Button.new(theme: :funky) %>
  #
  # === Reference Implementation
  #
  # This is a reference implementation for a central +Button+ component allowing
  # you to call different themes through a single component. Theme and subject
  # do not have to share a common ancestor.
  #
  #   class Gustwave::Button < Gustwave::Component
  #     include Gustwave::Themeable
  #
  #     register_theme :outline, "Ui::Buttons::Outline"
  #     register_theme :funky, "Ui::Buttons::Funky"
  #     # Optional, defaults to the first registered theme
  #     with_default_theme :outline
  #
  #     # Allow the caller to access themed_button methods and slots
  #     delegate_missing_to :themed_button
  #
  #     def initialize(theme: :outline, **options)
  #       @theme = theme
  #       @options = options
  #     end
  #
  #     def call
  #       render themed_button do
  #         content
  #       end
  #     end
  #
  #     private
  #
  #     def themed_button
  #       @themed_button ||= themed_component(@theme).new(**@options)
  #     end
  #   end
  #
  # === Registering themes from the outside
  #
  # Applications can add themes to a subject they don't own. Register them in
  # +to_prepare+, so that they are registered again when the subject class is
  # reloaded in development:
  #
  #   # config/initializers/gustwave.rb
  #   Rails.application.config.to_prepare do
  #     Gustwave::Button.register_theme :funky, "Ui::Buttons::Funky"
  #   end
  #
  # Don't register them in an initializer outside +to_prepare+: initializers
  # run once at boot, and the reloaded subject class won't know the theme.
  #
  # Alternatively, subclass the subject. Subclasses inherit the registered
  # themes and are reloaded along with their own registrations:
  #
  #   class Ui::Button < Gustwave::Button
  #     register_theme :funky, "Ui::Buttons::Funky"
  #   end
  module Themeable
    extend ActiveSupport::Concern

    # Raised when a theme is not found
    class ThemeNotFoundError < Gustwave::Error; end

    included do
      # Registered theme class names by theme name. Use +themes+ or
      # +themed_component+ instead of accessing this hash directly.
      class_attribute :__themes,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: {}

      # The default theme name.
      #
      # Set this through +with_default_theme+. Safe to access directly.
      class_attribute :default_theme,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: nil
    end

    class_methods do
      # Registers a theme for the calling class.
      #
      # Register the same class under several names to provide aliases.
      #
      # === Examples
      #
      #   class Gustwave::Button < Gustwave::Component
      #     register_theme :default_outline, "Gustwave::Buttons::DefaultOutline"
      #     register_theme :outline, "Gustwave::Buttons::DefaultOutline"
      #   end
      #
      # +Gustwave::Button+ can access the theme by calling
      # +themed_component(:default_outline)+ or +themed_component(:outline)+.
      #
      # @param name [Symbol] The name of the theme. Defines how it is accessed in the subject class, e.g. through a +theme+ argument in the constructor.
      # @param class_name [String] The name of the theme class. Resolved when the theme is requested.
      def register_theme(name, class_name)
        self.__themes = __themes.merge(name.to_sym => class_name.to_s)
        nil
      end

      # Sets the default theme of the calling class.
      #
      # This theme acts as a fallback in production when the theme name is not
      # found when calling +themed_component+. If not specified, the first
      # registered theme is used.
      #
      # @param theme_name [Symbol] The name of the theme.
      def with_default_theme(theme_name)
        self.default_theme = theme_name&.to_sym
      end

      # Returns the registered theme classes by theme name.
      #
      # @return [Hash{Symbol => Class}]
      def themes
        __themes.transform_values(&:constantize)
      end
    end

    # Returns the default theme name, or the first registered theme name if
    # none is set.
    def default_theme
      self.class.default_theme || self.class.__themes.keys.first
    end

    # Fetches the theme class for the given +theme+ name.
    #
    # Raises a +ThemeNotFoundError+ outside of production, letting the
    # developer know that the supplied theme name is invalid and what their
    # options are.
    #
    # In production, it falls back to the default theme. If no theme is
    # registered, raises a +ThemeNotFoundError+.
    #
    # @param theme [Symbol, nil] The name of the theme. Uses the default theme when +nil+.
    # @return [Class] The theme class.
    def themed_component(theme)
      resolve_theme_class_name(theme.presence&.to_sym || default_theme).constantize
    end

    private

    def resolve_theme_class_name(theme_name)
      themes = self.class.__themes
      class_name = themes[theme_name]
      return class_name if class_name

      unless Rails.env.production?
        raise ThemeNotFoundError, <<~MSG
          Invalid theme for #{self.class.name}.

          Expected one of: #{themes.keys.inspect}
          Got: #{theme_name.inspect}

          This will not raise in production, but will instead fallback to #{default_theme.inspect}.
        MSG
      end

      themes[default_theme] || raise(ThemeNotFoundError, "No themes registered for #{self.class.name}")
    end
  end
end
