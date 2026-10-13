# frozen_string_literal: true

module Gustwave
  # Provides a system for managing and composing CSS classes in ViewComponent
  #
  # It supports reusable +styling+ configurations, variations, default fallbacks,
  # and inheritance.
  #
  # === Overview
  #
  # The Styling concern offers abstraction for managing CSS classes in
  # ViewComponents, particularly for components with multiple visual states,
  # themes, or configuration options.
  #
  # === Key Features
  #
  # - Define reusable style configurations with named variations
  # - Inheritance of style definitions from parent components
  # - Support for default variations and fallback behavior
  # - Smart merging of CSS classes with conflict resolution via TailwindMerge
  # - Runtime validation of styling configurations in development
  # - Graceful fallback behavior in production
  # - Clear separation between component logic and styling concerns
  #
  # === Basic Usage Pattern
  #
  # 1. Include the module in your component
  # 2. Define your stylings using the +styling+ method
  # 3. Apply them with +compose_design+ in your component's render methods
  #
  # === Advantages
  #
  # - Makes component styling more maintainable and self-documenting
  # - Promotes consistent styling patterns across your application
  # - Simplifies the creation of components with multiple visual states
  # - Reduces duplication of CSS class strings throughout your codebase
  # - Allows for easier theme customization and variation
  #
  # TODO make merger customizable
  module Styling
    extend ActiveSupport::Concern

    module StylingHelpers
      module_function

      def build_styling(name, variations, default)
        {
          name => {
            variations: variations.compact,
            default: default
          }
        }
      end

      def resolve_default(styling_name, new_default, variations, data)
        if new_default
          stored_keys = data.dig(styling_name, :variations)&.keys.to_a
          valid_keys = variations.keys.concat(stored_keys)

          return new_default if new_default.in?(valid_keys)
          raise StylingErrors::DefaultArgumentError.new(
            styling_name,
            given: new_default,
            expected: valid_keys,
            fallback: variations.keys.last
          ) unless Rails.env.production?
        end

        stored_default = data.dig(styling_name, :default)
        return stored_default if stored_default

        return :on if variations.keys.all? { |key| key.in?([ :on, :off ]) }
        return :default if variations.key?(:default)

        variations.keys.last
      end

      def normalize_key(key)
        return if key.nil?
        return :on if key == true
        return :off if key == false

        key.to_sym
      end
    end

    module StylingErrors
      # Raised when a styling is used that does not exist
      class StylingArgumentError < FetchOrFallbackError
        def initialize(given:, expected:)
          headline = "Invalid styling provided."
          super(headline, given:, expected:)
        end
      end

      # Raise when an invalid variation is used in +compose_design+
      class VariationArgumentError < FetchOrFallbackError
        def initialize(styling_name, given:, expected:, fallback:)
          headline = "Invalid variation provided for styling #{styling_name.inspect}"
          super(headline, given:, expected:, fallback:)
        end
      end

      # Raised when the default is not one of the variations
      class DefaultArgumentError < FetchOrFallbackError
        def initialize(styling_name, given:, expected:, fallback:)
          headline = "Invalid default provided for styling #{styling_name.inspect}"
          super(headline, given:, expected:, fallback:)
        end
      end
    end

    # Defined here to benefit from TailwindMerge's caching mechanism
    MERGER = TailwindMerge::Merger.new
    # When calling +compose_design+, you can use these keywords as prefixes or
    # postfixes to add additional classes, without needing to define a separate
    # style first, e.g.:
    #
    #   compose_design(scheme: :blue, class: "bg-white")
    #
    # Multiple keywords can be used in the same call, provided that each is
    # distinct.
    #
    #   compose_design(background_class: "bg-white", class: "inline-flex", classy: "text-yellow-800")
    #
    # Generic keywords do not interfere with styling names. This still works:
    #
    #   styling(:class, variants: { white: "bg-white" })
    #   compose_design(class: :white, text_class: "text-gray-800")
    #   # => "bg-white text-gray-800"
    #   compose_design(class: "bg-gray-50", text_class: "text-gray-800")
    #   # => "bg-gray-50 text-gray-800"
    GENERIC_STYLING_KEYS = %w[class custom].freeze

    included do
      class_attribute :__stylings,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: {}
    end

    class_methods do
      # Registers or updates a component styling
      #
      # Stylings are inheritable and customizable, meaning inheriting classes
      # can modify a previously defined styling without affecting the parent
      # class.
      #
      # A styling has a key and a set of variations. Compose multiple stylings
      # to a design through the +compose_design+ method.
      #
      # === Defining a singular styling
      #
      # In the simplest form, you can define a styling with a single variation.
      #
      #   styling(:base, "flex items-center")
      #
      # This defines the styling with the name :base, two variations :on and :off,
      # where :on takes the +variation+ value and :off is an empty string. The
      # default is set to :on. There are two ways to access it:
      #
      #   compose_design(base: true)
      #   # => "flex items-center"
      #   compose_design(base: :on)
      #   # => "flex items-center"
      #
      # === Defining a styling with multiple variations
      #
      # Use +variations+ to distinguish between alternatives for the same thing,
      # e.g. size or color scheme.
      #
      #   styling :scheme,
      #           variations: {
      #             none: "",
      #             blue: "bg-blue-500 text-white",
      #             green: "bg-green-500 text-gray-800"
      #           }
      #
      # Accessing the styling with a variation key will return the CSS classes
      # for that variation.
      #
      #   compose_design(scheme: :blue)
      #   # => "bg-blue-500 text-white"
      #
      # === Setting a default variation
      #
      # Setting the default variation has two purposes: it sets the fallback
      # variation when an invalid variation is used in production, and it is
      # returned by the auto-generated +<styling_name>_styling_default+ method.
      #
      # When omitted, the method looks for a variation with the key :default. If
      # no such variation is found, it uses the last variation in the hash.
      #
      #   styling :scheme,
      #           variations: {
      #             none: "",
      #             default: "bg-gray-500",
      #             blue: "bg-blue-500"
      #           }
      #   scheme_styling_default
      #   # => :default
      #
      #   styling :scheme, variations: { none: "", blue: "bg-blue-500" }
      #   scheme_styling_default
      #   # => :blue
      #
      # When specified, it must match one of the keys in the +variations+ hash.
      #
      #   styling :scheme,
      #           variations: { none: "", blue: "bg-blue-500" },
      #           default: :none
      #   scheme_styling_default
      #   # => :none
      #
      # === Conflict resolution
      #
      # When a styling with the same name already exists, the new variations are
      # merged with the existing ones. Merging acts like Ruby's +Hash#merge+
      # method. Each new-key entry is added at the end of the existing hash.
      # Each duplicated-key entry's value overwrites the previous value.
      #
      # If a default is given, it overwrites the previous default.
      #
      # === Inheritance
      #
      # Stylings automatically inherit from parent classes. This means that you
      # can build up on previously defined stylings in parent classes, modify
      # them, or add new ones. Modifications have no effect on the parent class.
      #
      # @param name [Symbol] The name of the styling. This is how the name is referred to in the +compose_design+ method.
      # @param variation [String, NilClass] Pass a CSS class string to define a single variation styling. Generates the +variations+ hash: { on: variation, off: "" }, with default set to :on.
      # @param variations [Hash] A hash of variations. Each key is a variation name. Each value is a CSS class string.
      # @param default [Symbol, NilClass] The default variation. Must be one of the keys in the +variations+ hash. If omitted, it is set to :default if the +variations+ hash contains a key with the key :default. If no such key is found, it uses the last key in the hash.
      def styling(name, variation = nil, variations: {}, default: nil)
        raise ArgumentError, "Variations must be a hash" unless variations.is_a?(Hash)

        copy_styling_class_attributes_if_shared
        data = self.__stylings
        variations =
          if variation.is_a?(String)
            { on: variation, off: "" }
          else
            variations.symbolize_keys
          end

        raise ArgumentError, "Variations can't be empty" if data.dig(name).nil? && variations.empty?

        default = StylingHelpers.resolve_default(name, default, variations, data)
        styling_hash = StylingHelpers.build_styling(name, variations, default)
        data.deep_merge!(styling_hash)

        define_styling_methods(name)
        self.__stylings = data

        nil
      end

      # Removes a styling from the class
      #
      # Removes the styling, its variations, and getter methods. Does not
      # alter the parent class.
      #
      # It does however, alter inheritance behavior:
      #
      #   class BaseComponent < ApplicationComponent
      #     include Gustwave::Styling
      #
      #     styling :base, "flex items-center"
      #     styling :scheme, variations: { none: "", blue: "bg-blue-500" }
      #   end
      #
      #   class FooComponent < BaseComponent
      #     styling :scheme, variations: { green: "bg-green-500" }
      #   end
      #
      #   FooComponent.new.compose_design(base: true)
      #   # Inherits from BaseComponent
      #   # => "flex items-center"
      #   FooComponent.new.compose_design(scheme: :blue)
      #   # Inherits from BaseComponent
      #   # => "bg-blue-500"
      #
      #   class BarComponent < BaseComponent
      #     undef_styling :scheme
      #   end
      #
      #   BarComponent.new.compose_design(base: true)
      #   # Inherits from BaseComponent
      #   # => "flex items-center"
      #   BarComponent.new.compose_design(scheme: :blue)
      #   # Does not inherit from BaseComponent anymore
      #   # => raises InvalidStylingError
      #   BaseComponent.new.compose_design(scheme: :blue)
      #   # BaseComponent unaffected
      #   # => "bg-blue-500"
      #
      # @param name [Symbol] The name of the styling to remove.
      def undef_styling(name)
        copy_styling_class_attributes_if_shared

        self.__stylings.delete(name)
        undef_styling_methods(name)

        nil
      end
      alias remove_styling undef_styling

      # Replaces a styling with a new one
      #
      # First removes the old styling, then creates a new one under the same
      # name. This method is not transactional, meaning it won't restore the
      # previous styling if creating the new one fails.
      #
      # @param name [Symbol] The name of the styling to replace. This is how the name is referred to in the +compose_design+ method.
      # @param variation [String, NilClass] Pass a CSS class string to define a single variation styling. Generates the +variations+ hash: { on: variation, off: "" }, with default set to :on.
      # @param variations [Hash] A hash of variations. Each key is a variation name. Each value is a CSS class string.
      # @param default [Symbol, NilClass] The default variation. Must be one of the keys in the +variations+ hash. If omitted, it is set to :default if the +variations+ hash contains a key with the key :default. If no such key is found, it uses the last key in the hash.
      def replace_styling(name, variation = nil, variations: {}, default: nil)
        undef_styling(name)
        styling(name, variation, variations:, default:)
      end

      private

      def define_styling_methods(name) # :nodoc:
        prefix = name.to_s.downcase.tr("-", "_")

        define_method :"#{prefix}_styling_default" do
          self.class.__stylings.dig(name, :default)
        end

        define_method :"#{prefix}_styling_variations" do
          self.class.__stylings.dig(name, :variations).deep_dup
        end
      end

      def undef_styling_methods(name) # :nodoc:
        prefix = name.to_s.downcase.tr("-", "_")
        methods = %w[styling_default styling_variations]

        methods.each do |method_name|
          name = [ prefix, method_name ].join("_")
          undef_method(name) if method_defined?(name)
        end
      end

      def copy_styling_class_attributes_if_shared
        if self.__stylings.object_id == self.superclass.__stylings.object_id
          self.__stylings = __stylings.deep_dup
        end
      end
    end

    # Returns a string of CSS classes for the given styling selection and
    # additional generic values
    #
    # The method applies the selection in the supplied order. Generic values and
    # styling keys can be mixed freely. The resulting class string is passed
    # through TailwindMerge::Merger to semantically merge conflicting classes.
    #
    # === Usage
    #
    # Assuming a basic component:
    #
    #   class BasicComponent < ApplicationComponent
    #     includes Gustwave::Styling
    #
    #     styling :base, "flex items-center"
    #     styling :scheme,
    #             variations: {
    #               none: "",
    #               blue: "bg-blue-500 text-white"
    #             }
    #   end
    #
    # Use +compose_design+ to combine a styling selection with additional
    # generic CSS class strings:
    #
    #   compose_design(base: :on, scheme: :blue, class: "text-gray-800"))
    #   # => "flex items-center bg-blue-500 text-gray-800"
    #
    # Alternatively, you can refer to :on and :off variations through Booleans:
    #
    #   compose_design(base: true, scheme: :blue, class: "text-gray-800"))
    #   # => "flex items-center bg-blue-500 text-gray-800"
    #
    # Selections with +nil+ values are ignored:
    #
    #   compose_design(base: :on, scheme: nil, class: "text-gray-800"))
    #   # => "flex items-center text-gray-800"
    #
    # Be aware that Booleans are always converted to :on and :off. This means
    # that this call raises an InvalidStylingVariationError outside production
    # and falls back to the default variation in production:
    #
    #   # scheme does not contain an :off variation
    #   compose_design(base: true, scheme: false, class: "text-gray-800"))
    #   # => raises InvalidStylingVariationError
    #
    # === Generic keywords
    #
    # You can freely combine generic CSS class strings with defined styling
    # variations. By default, any key that starts or ends with +class+ or +custom+
    # and has a String value is treated as a generic CSS class string.
    #
    #   compose_design(
    #     classic: "text-gray-200",
    #     class: "bg-white",
    #     border_class: "border"
    #   )
    #   # => "text-gray-200 bg-white border"
    #
    # These keywords are not reserved. You can still use them as styling names
    # if needed.
    #
    #   class SomeComponent < ApplicationComponent
    #     include Gustwave::Styling
    #
    #     styling :visuals_class, "flex w-full"
    #     styling :class, variations: { white: "bg-white" }
    #   end
    #
    #   compose_design(
    #     visuals_class: true,
    #     class: :white,
    #     text_class: "text-gray-800"
    #   )
    #   # => "flex w-full bg-white text-gray-800"
    #
    # === Default value fallback and exceptions
    #
    # In production, referencing a non-existent styling key will simply ignore
    # that part of the selection. In other environments, this raises an
    # InvalidStylingError and lists the available styling options.
    #
    # Referencing a non-existent variation will fall back to the default
    # variation in production. In other environments, this raises an
    # InvalidStylingVariationError and lists the available variations.
    #
    # @param selection [Hash] A hash of styling keys and values. Use generic keywords to add additional classes, without needing to define a separate styling first, e.g.: +compose_design(class: "bg-white")+. See +GENERIC_STYLING_KEYS+ for the list of recognized generic keywords.
    def compose_design(**selection)
      selection.compact!

      classes = [].tap do |classes|
        selection.each do |styling_key, variation_key_or_generic_value|
          if generic_styling?(styling_key, variation_key_or_generic_value)
            classes << variation_key_or_generic_value # generic value
          else
            classes << variation_or_default_value(styling_key, variation_key_or_generic_value)
          end
        end
      end

      MERGER.merge(classes.compact_blank!).presence
    end

    private

    def generic_styling?(key, value)
      return false unless value.is_a?(String)

      key.start_with?(*GENERIC_STYLING_KEYS) || key.end_with?(*GENERIC_STYLING_KEYS)
    end

    # Normalizes key to access a styling
    #
    # Converts boolean to :on and :off. Symbolizes all other values.
    #
    # @param key [Object] The key to normalize.
    # @return [Symbol] The normalized variation key.
    def normalize_variation_key(key)
      return :on if key == true
      return :off if key == false

      key.to_sym
    end

    def variation_or_default_value(styling_key, variation_key)
      data = self.class.__stylings
      variation_key = normalize_variation_key(variation_key)

      variations = data.fetch(styling_key) do |key|
        unless Rails.env.production?
          raise StylingErrors::StylingArgumentError.new(given: key, expected: data.keys)
        end

        {}
      end.fetch(:variations, {})

      value = variations.fetch(variation_key) do |key|
        default_key = data.dig(styling_key, :default)

        unless Rails.env.production?
          raise StylingErrors::VariationArgumentError.new(
            styling_key,
            given: key,
            expected: variations.keys,
            fallback: default_key
          )
        end

        variations.dig(default_key)
      end

      value.to_s
    end
  end
end
