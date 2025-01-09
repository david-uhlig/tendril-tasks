# frozen_string_literal: true

module Gustwave
  module Themeable
    extend ActiveSupport::Concern

    included do
      class_attribute :themes,
                      instance_writer: false,
                      instance_predicate: false,
                      default: {}
      class_attribute :default_theme,
                      instance_writer: false,
                      default: nil
    end

    class_methods do
      # Registers the theme for the current class in its parent or specified target
      def theme_for_parent(as: nil)
        parent_class = ancestors[1] # Get the direct parent class
        theme_for(parent_class, as: as || infer_theme_name)
      end

      # Registers the theme for a specific target class
      def theme_for(target, as: nil)
        as = as&.to_sym
        target.themes[as || infer_theme_name] = self
        target.default_theme ||= as
      end

      # Registers the default theme for the current class
      def with_default_theme(theme_name)
        self.default_theme = theme_name&.to_sym
      end

      private

      # Infers the theme name from the class name
      def infer_theme_name
        name.demodulize.underscore.to_sym
      end
    end

    # Fetches the appropriate theme class based on the provided theme name
    def themed_component(theme)
      resolve_theme_class(theme)
    end

    private

    # Resolves the appropriate theme class
    def resolve_theme_class(theme_name)
      klass = self.class.themes.dig(theme_name.to_sym)
      if klass.nil? && !Rails.env.production?
        raise ArgumentError, <<~MSG
          Invalid theme for #{self.class.name}.

          Expected one of: #{self.class.themes.keys.inspect}
          Got: #{theme_name.to_sym}

          This will not raise in production, but will instead fallback to #{self.class.default_theme}.
        MSG
      end

      klass || self.class.themes[self.class.default_theme]
    end
  end
end
