module Gustwave
  # Provides QoL features and improved DX for defining class-level hashes and
  # accessing them on the instance level through a getter method.
  #
  # Generates a +NAME_mapping+ getter, that returns the mapped hash without
  # arguments, and the object accessed by +map.dig(key, *identifiers)+ with
  # arguments. The getter name can be fully customized.
  #
  # Outside Rails.env.production, it raises MappingErrors::ArgumentError when
  # accessing a key that is not in the hash. Provides a convenient error message
  # outlining the valid options.
  #
  # In production, falls back to a configurable default value.
  module Mapping
    extend ActiveSupport::Concern

    module MappingHelpers
      module_function

      def resolve_fallback(mapping_name, map, fallback)
        return fallback if fallback.present? && map.key?(fallback)
        return nil if map.empty?
        return map.keys.first if fallback.blank?

        unless Rails.env.production?
          raise MappingErrors::DefaultArgumentError.new(
            mapping_name,
            given: fallback,
            expected: map.keys,
            fallback: map.keys.first
          )
        end

        map.keys.first
      end

      def getter_method_name(mapping_name, custom_getter_name)
        return custom_getter_name if custom_getter_name.present?

        "#{mapping_name.to_s.tr("-", "_")}_mapping".to_sym
      end
    end

    module MappingErrors
      class ArgumentError < Gustwave::FetchOrFallbackError
        def initialize(name, given:, expected:, fallback:)
          headline = "Invalid key provided for mapping #{name.inspect}"
          super(headline, given:, expected:, fallback:)
        end
      end

      # Raised when the default is invalid
      class DefaultArgumentError < Gustwave::FetchOrFallbackError
        def initialize(name, given:, expected:, fallback:)
          headline = "Invalid default provided for mapping #{name.inspect}"
          super(headline, given:, expected:, fallback:)
        end
      end
    end

    included do
      class_attribute :__mappings,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: {}

      class_attribute :__mapping_getter_names,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: {}
    end

    class_methods do
      # Defines a hash with QoL features enhancing the DX
      #
      # When accessing the mapped hash with an invalid first-level key, it:
      # - raises a MappingErrors::ArgumentError outside +Rails.env.production+ with a detailed error message showing the valid options.
      # - silently falls back to a default value in production.
      #
      # Creates a +NAME_mapping+ getter, that returns the mapped hash without
      # arguments and the object accessed by +map.dig(key, *identifiers)+
      # otherwise. Use the +as+ option to define a custom getter name.
      #
      # The QoL features work regardless of accessing the first-level hash keys
      # through the +NAME_mapping+ getter or through the hash directly.
      #
      # Caution: The returned object is mutable by design. Modifying it inplace
      # might lead to unexpected behavior.
      #
      # === Defining a mapping
      #
      # In the simplest form, you can define a mapping with an empty hash:
      #
      #   class Example
      #     include Gustwave::Mapping
      #
      #     mapping :foo, {}
      #   end
      #
      #   example = Example.new
      #   example.foo_mapping
      #   # => {}
      #   example.foo_mapping(:invalid)
      #   # => nil in production, raises MappingErrors::ArgumentError otherwise
      #
      # The real value comes with non-empty hashes:
      #
      #   class Example
      #     include Gustwave::Mapping
      #
      #     mapping :foo_to_bar, {
      #       foo: :bar,
      #       bar: :baz
      #     }
      #   end
      #
      #   example = Example.new
      #   example.foo_to_bar_mapping
      #   # => { foo: :bar, bar: :baz }
      #   example.foo_to_bar_mapping(:foo)
      #   # => :bar
      #   example.foo_to_bar_mapping(:invalid)
      #   # No fallback specified, falls back to first value
      #   # => :bar in production, raises MappingErrors::ArgumentError otherwise
      #
      # === Defining a fallback
      #
      # You can define a fallback value for invalid keys (first-level of the hash only):
      #
      #   class Example
      #     include Gustwave::Mapping
      #
      #     mapping :foo_to_bar, {
      # 	    foo: :bar,
      # 	    bar: :baz
      # 	  }, fallback: :bar
      #   end
      #
      #   Example.new.foo_to_bar_mapping(:invalid)
      #   # => :baz in production, raises MappingErrors::ArgumentError otherwise
      #
      # === Defining a custom getter name
      #
      # You can define a custom getter name for the mapping:
      #
      #   class Example
      #     include Gustwave::Mapping
      #
      #     mapping :foo_to_bar, {}, as: :this_can_be_anything_really
      #   end
      #
      #   Example.new.this_can_be_anything_really
      #   # => {}
      #
      # === Access mapping from parent classes
      #
      # You can access mappings from parent classes:
      #
      #   class Example
      #     include Gustwave::Mapping
      #
      #     mapping :foo_to_bar, { foo: :bar }
      #   end
      #
      #   class ChildExample < Example; end
      #
      #   ChildExample.new.foo_to_bar_mapping
      #   # => { foo: :bar }
      #
      # Caution: While invoking +mapping+ on a child class does not alter the
      # parent class, modifying the returned hash in this example would alter
      # the parent class!
      #
      #   ChildExample.new.foo_to_bar_mapping.merge!(baz: :qux)
      #   Example.new.foo_to_bar_mapping
      #   # => { foo: :bar, baz: :qux } # Oopsie!
      #
      # @param name [Symbol] The name of the mapping.
      # @param map [Hash] A hash where keys are input values and values are output values. Must contain at least one key.
      # @param fallback [Symbol, NilClass] The key used to retrieve a fallback value if map is accessed with an invalid key in production. If given, must exist in +map.keys+. Defaults to +map.keys.first+.
      # @param as [Symbol, NilClass] Defines a custom getter name for the mapping. Otherwise, the getter name is derived automatically +<name>_mapping+.
      def mapping(name, map, fallback: nil, as: nil)
        raise ArgumentError, "Map must be a hash" unless map.is_a?(Hash)

        copy_mapping_class_attributes_if_shared
        fallback = MappingHelpers.resolve_fallback(name, map, fallback)

        self.__mappings[name] = map
        self.__mappings[name].default_proc =
          proc do |hash, key|
            unless Rails.env.production?
              raise MappingErrors::ArgumentError.new(name, given: key, expected: hash.keys, fallback: fallback)
            end

            hash[fallback] if fallback.present?
          end

        getter_method_name = MappingHelpers.getter_method_name(name, as)
        define_method getter_method_name do |*keys|
          self.class.__mappings.dig(name, *keys)
        end
        self.__mapping_getter_names[name] = getter_method_name

        nil
      end

      # Removes a mapped hash and its getter method from the class
      #
      # Won't affect parent classes. It will affect "look through" behavior.
      # Before applying +undef_mapping+, the child class can see a mapping
      # defined in a parent class. After applying +undef_mapping+ on the child
      # class, the parent's mapping will be hidden.
      #
      # @param name [Symbol] The name of the mapping to remove. Caution: Not the name of the getter method!
      def undef_mapping(name)
        return unless self.__mappings.key?(name)

        copy_mapping_class_attributes_if_shared

        getter_method_name = self.__mapping_getter_names[name]
        undef_method(getter_method_name) if method_defined?(getter_method_name)

        self.__mappings.delete(name)
        self.__mapping_getter_names.delete(name)

        nil
      end

      private

      def copy_mapping_class_attributes_if_shared
        if self.__mappings.object_id == self.superclass.__mappings.object_id
          self.__mappings = __mappings.dup
          self.__mapping_getter_names = __mapping_getter_names.dup
        end
      end
    end
  end
end
