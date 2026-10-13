# frozen_string_literal: true

module Gustwave
  # Use Themeable to access interchangeable, themed components through a
  # centralized component.
  #
  # This is a specialization of the Strategy pattern where the +subject+ class
  # acts as the strategy and the +theme+ classes provide the concrete
  # implementation.
  #
  # The concern provides functionality for both, the +subject+ class and the
  # +theme+ classes.
  #
  # On the theme classes:
  # - Use +theme_for+ and +theme_for_parent+ to register the +theme+ at the +subject+ class.
  #
  # On the subject class:
  # - Use +with_default_theme+ to set the default +theme+. (Optional)
  # - Use +themed_component+ to access the +theme+ class.
  #
  # === Benefits
  #
  # This can lead to much cleaner frontend code, e.g. instead of calling
  #   <%= render Gustwave::Buttons::GradientDuotone.new %>
  #   <%= render Ui::Buttons::Funky.new %>
  #   <%= render Extension::SupercoolButtonComponent.new %>
  # you can access all themes through a centralized component
  #   <%= render Gustwave::Button.new(theme: :gradient_duotone) %>
  #   <%= render Gustwave::Button.new(theme: :funky) %>
  #   <%= render Gustwave::Button.new(theme: :supercool) %>
  #
  # === Reference Implementation
  #
  # This is a reference implementation for a central +Button+ component allowing
  # you to call different themes through a single component.
  #
  #   class Gustwave::Button < Gustwave::Component
  #     include Gustwave::Themeable # Usually already included by Gustwave::Component
  #
  #     # Allow the caller to access themed_button methods and slots
  #     delegate_missing_to :themed_button
  #     # Optional
  #     with_default_theme :outline
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
  # This is a reference implementation for an outline theme. Theme and subject
  # do not have to share a common ancestor.
  #
  #   class Ui::Buttons::Outline < Gustwave::Component
  #     include Gustwave::Themeable # Usually already included by Gustwave::Component
  #
  #     theme_for Gustwave::Button
  #
  #     def initialize(**options)
  #       @options = options
  #     end
  #
  #     def call
  #       content_tag :button, @options do
  #         content
  #       end
  #     end
  #   end
  module Themeable
    extend ActiveSupport::Concern

    # Raised when a theme is not found
    class ThemeNotFoundError < Gustwave::Error; end

    included do
      # Registered themes.
      #
      # The key is the theme name, the value is the theme class. Instead of
      # accessing this hash directly, use +themed_component+ instead.
      class_attribute :themes,
                      instance_writer: false,
                      instance_predicate: false,
                      default: {}

      # The default theme.
      #
      # Set this through +with_default_theme+. If not set, the first theme that
      # registers itself through +theme_for+ or +theme_for_parent+ is used.
      #
      # Safe to access directly.
      class_attribute :default_theme,
                      instance_writer: false,
                      default: nil
    end

    class_methods do
      # Registers the calling class as a theme for the subject class.
      #
      # === Examples
      # Registers +Gustwave::Buttons::GradientDuotone+ as a theme for
      # +Gustwave::Button+. Note: Usually, +Gustwave::Themeable+ is already
      # included through +Gustwave::Component+.
      #
      # +Gustwave::Button+ can access the theme by calling
      # +themed_component(:gradient_duotone)+.
      #
      #   class Gustwave::Buttons::GradientDuotone < Gustwave::Component
      #     include Gustwave::Themeable
      #
      #     theme_for Gustwave::Button
      #   end
      #
      # Registers +Gustwave::Buttons::GradientDuotone+ with the theme name
      # +duotone+ for +Gustwave::Button+.
      #
      # +Gustwave::Button+ can access the theme by calling
      # +themed_component(:duotone)+, but not by calling +themed_component(:gradient_duotone)+.
      #
      #   class Gustwave::Buttons::GradientDuotone < Gustwave::Component
      #     include Gustwave::Themeable
      #
      #     theme_for Gustwave::Button, as: :duotone
      #   end
      #
      # You can use this behavior to provide aliases for the theme name. This
      # example makes the component accessible through +duotone+ and +gradient_duotone+.
      #
      #   class Gustwave::Buttons::GradientDuotone < Gustwave::Component
      #     include Gustwave::Themeable
      #
      #     theme_for Gustwave::Button
      #     theme_for Gustwave::Button, as: :duotone
      #   end
      #
      # @param subject [Class] The class being themed.
      # @param as [Symbol] The name of the theme. Defines how it is accessed in the subject class, e.g. through a +theme+ argument in the constructor. Defaults to an underscored version of the class name, without modules, e.g. +Gustwave::GradientDuotone+ becomes +gradient_duotone+.
      def theme_for(subject, as: nil)
        theme_name = as&.to_sym || infer_theme_name
        subject.themes = subject.themes.merge(theme_name => self)
        subject.default_theme ||= theme_name
        theme_name
      end

      # Registers the calling class as a theme for the direct ancestor.
      #
      # @param as [Symbol] The name of the theme. Defines how it is accessed in the subject class, e.g. through a +theme+ argument in the constructor. Defaults to an underscored version of the class name, without modules, e.g. +Gustwave::GradientDuotone+ becomes
      # @see +theme_for+
      def theme_for_parent(as: nil)
        parent_class = ancestors[1] # Get the direct parent class
        theme_for(parent_class, as:)
      end

      # Determines the default theme on the calling class.
      #
      # This theme class acts as a fallback theme when the theme name is not
      # found when calling +themed_component+. If not specified, the first class
      # registered through +theme_for+ or +theme_for_parent+ is used.
      #
      # Note: There are no validations for the theme name because class loading
      # order is not guaranteed.
      #
      # @param theme_name [Symbol] The name of the theme.
      def with_default_theme(theme_name)
        self.default_theme = theme_name&.to_sym
      end

      private

      # Infers the theme name from the class name
      #
      # === Examples
      #   Gustwave::Buttons::GradientDuotone
      #   # => gradient_duotone
      #   Button
      #   # => button
      def infer_theme_name
        name.demodulize.underscore.to_sym
      end
    end

    # Fetches the theme class for the given +theme+ name.
    #
    # The advantage of this method over accessing the +themes+ hash directly
    # is that it raises a +ThemeNotFoundError+ outside of production, letting
    # the developer know that the supplied theme name is invalid and what their
    # options are.
    #
    # In production, it falls back to the default theme or the first theme in
    # the +themes+ hash. If everything fails, raises a +ThemeNotFoundError+.
    #
    # @param theme [Symbol] The name of the theme.
    # @return [Class] The theme class.
    def themed_component(theme)
      resolve_theme_class(theme)
    end

    private

    # :nodoc:
    #
    # @see +themed_component+
    def resolve_theme_class(theme_name)
      klass = self.class.themes.dig(theme_name.to_sym)
      if klass.nil? && !Rails.env.production?
        raise ThemeNotFoundError, <<~MSG
          Invalid theme for #{self.class.name}.

          Expected one of: #{self.class.themes.keys.inspect}
          Got: #{theme_name.to_sym}

          This will not raise in production, but will instead fallback to #{self.class.default_theme}.
        MSG
      end

      klass || self.class.themes.dig(self.class.default_theme) || self.class.themes.values.first || raise(ThemeNotFoundError, "No themes registered for #{self.class.name}")
    end
  end
end
