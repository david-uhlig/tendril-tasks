# frozen_string_literal: true

require "tailwind_merge"
require "active_support/concern"
require "active_support/core_ext/class/attribute"

module Gustwave
  module Styleable
    extend ActiveSupport::Concern

    # Raised when an invalid key is used in +styles+
    class InvalidStyleDefinitionError < Gustwave::Error; end

    # Raised when an invalid state is used for a style definition
    class InvalidStyleError < Gustwave::Error; end

    # Defined here to benefit from TailwindMerge's caching mechanism.
    MERGER = TailwindMerge::Merger.new

    included do
      class_attribute :__style_layers,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: {}
    end

    class_methods do
      # Registers or updates an inheritable and customizable style layer for a
      # component.
      #
      # === Defining a style layer
      #
      # Defines a style layer with the name +scheme+ that has two states: +none+
      # and +gray+. By default, the :merge strategy is used, which means that the
      # new states will be merged with the existing states from previous
      # +style_layer+ calls in the same component or parent components. The
      # +default:+ option defines the default state for the layer. The default
      # state must be one of the keys in the +states+ hash. It is used as the
      # fallback state in production when an undefined state is specified. It
      # can be retrieved using the +default_layer_state+ method.
      #
      #   style_layer :scheme, {
      #     none: "",
      #     gray: "text-gray-900",
      #   }, default: :gray
      #
      # === Reserved keywords
      #
      # All keywords starting with +custom*+ are reserved layer names that
      # cannot be used as style layer names. They are used to apply custom
      # classes to the component in the +styles+ method.
      #
      # Boolean values are mapped to the :on and :off state in the +merge_layers+
      # method. This is useful for style layers that have a binary state, like
      # a :base layer.
      #
      #   style_layer :base, {
      #     on: "text-gray-900 dark:text-white",
      #     off: ""
      #   }, default: :on
      #
      # === Merging states
      #
      # For updating or extending the states of an existing style layer, you can
      # call +style_layer+ again with the same layer name and the :merge
      # strategy.
      #
      # NOTE: This does not merge the CSS classes for the same state,
      # i.e. if the new state hash has a key-value pair for a state that already
      # exists in the existing state hash, the new value will replace the old
      # value.
      #
      # You can omit the +default:+ option when using the :merge strategy with a
      # style layer that already has a default state.
      #
      #   style_layer :scheme, {
      #     none: "",
      #     gray: "text-gray-900",
      #   }, default: :gray
      #
      #   style_layer :scheme, {
      #     gray: "dark:text-white",
      #     red: "text-red-700"
      #   }, strategy: :merge
      #
      # Resulting states hash:
      #
      #   {
      #     none: "", # Preserved
      #     gray: "dark:text-white", # Replaced
      #     red: "text-red-700" # Added
      #   }
      #
      # === Replacing states
      #
      # To replace the states of an existing style layer, you can call
      # +style_layer+ again with the same layer name and the :replace strategy.
      # This strategy clears the existing states and replaces them with the new
      # states.
      #
      # You have to specify the new default when using the :replace strategy.
      # Even if the new default is the same as the old default.
      #
      #   style_layer :scheme, {
      #     none: "",
      #     gray: "text-gray-900",
      #   }, default: :gray
      #
      #   style_layer :scheme, {
      #     gray: "dark:text-white",
      #     red: "text-red-700"
      #   }, default: :gray, strategy: :replace
      #
      # Resulting states hash:
      #
      #   {
      #     gray: "dark:text-white",
      #     red: "text-red-700"
      #   }
      #
      # === Removing a style layer
      #
      # To remove a style layer from the component, you can call +style_layer+
      # with the :clear strategy. This will remove the style layer from the
      # component. You don't have to specify the +states+ or +default+ options.
      #
      #  style_layer :scheme, strategy: :clear
      #
      # === Inheritance
      #
      # Style layers are automatically inherited by child components. So you can
      # build up on previously defined style layers in parent components, modify
      # them, or add new ones.
      #
      #   class ParentComponent < ApplicationComponent
      #     style_layer :scheme, {
      #       none: "",
      #       gray: "text-gray-900"
      #     }, default: :gray
      #   end
      #
      #   class ChildComponent < ParentComponent
      #     style_layer :scheme, {
      #       gray: "dark:text-white",
      #       red: "text-red-700"
      #     }, strategy: :merge
      #   end
      #
      # @param [Symbol] layer the name of the layer. This is the name that will
      #   be used to reference the layer in the component.
      #
      # @param states [Hash, nil] a hash of CSS classes that will be applied
      #   when the layer is used. The keys in the hash are the layer's states,
      #   and the values are the CSS classes that will be applied when the state
      #   is used.
      # @param default [Symbol, nil] the default state for the variant. Must be
      #   one of the keys of the +states+ hash.
      # @param strategy [Symbol] the strategy when updating the variant's state
      #   hash. One of :merge, :replace, and :clear. The :merge strategy will
      #   merge the new state hash with the existing state hash. NOTE: This does
      #   not merge the CSS classes for the same state, i.e. if the new state
      #   hash has a key-value pair for a state that already exists in the
      #   existing state hash, the new value will replace the old value. The
      #   :replace strategy will replace the existing state hash with the new
      #   state hash. You have to specify the new default when using the
      #   :replace strategy. The :clear strategy will remove the style layer
      #   from the component.
      # @return [nil]
      # @raise [ArgumentError] if the +states+ argument is not a hash.
      # @raise [ArgumentError] if the :merge strategy is used without the
      #   +default:+ option on new layers.
      # @raise [ArgumentError] if the :replace strategy is used without the
      #   +default:+ option.
      # @raise [ArgumentError] if the +default:+ option is not one of the keys
      #   in the +states+ hash (:merge and :replace only).
      # @raise [ArgumentError] if an invalid strategy is specified.
      def style_layer(layer, states = nil, default: nil, strategy: :merge)
        raise ArgumentError, "States must be a hash" unless states.is_a?(Hash)

        # Deep duplicate to avoid accidental mutations
        self.__style_layers = __style_layers.deep_dup

        case strategy
        when :merge
          if default.blank? && self.__style_layers[layer].blank?
            raise ArgumentError, "A default must be specified for the merge strategy"
          end

          merged_layer = self.__style_layers.dig(layer) || { states: {}, default: nil }
          merged_layer[:states].merge!(states)
          merged_layer[:default] = default if default.present?

          if default.present? && !merged_layer[:states].key?(default)
            raise ArgumentError, "Default must be one of the states keys"
          end

          self.__style_layers[layer] = merged_layer
        # TODO document this strategy
        when :combine
          if default.blank? && self.__style_layers[layer].blank?
            raise ArgumentError, "A default must be specified for the merge strategy"
          end

          merged_layer = self.__style_layers.dig(layer) || { states: {}, default: nil }
          merged_layer[:states].merge!(states) { |_, old, new| MERGER.merge([ old, new ]) }
          merged_layer[:default] = default if default.present?

          if default.present? && !merged_layer[:states].key?(default)
            raise ArgumentError, "Default must be one of the states keys"
          end

          self.__style_layers[layer] = merged_layer
        when :replace
          raise ArgumentError, "Default must be specified for replace strategy" unless default.present?
          raise ArgumentError, "Default must be one of the states keys" unless states.key?(default)

          self.__style_layers[layer] = { states: states, default: default }
        when :clear
          self.__style_layers.delete(layer)
        else
          raise ArgumentError, "Invalid strategy: #{strategy}"
        end

        nil
      end

      # Use +style+ to define a style group for a component
      #
      # @param group [Symbol] the name of the style group. This is the name that will be used to reference the group in the component.
      # @param state_or_states [Hash, String] a +String+ or +Hash+ of CSS classes that will be applied when the group is used. When a +String+ is passed, it will be automatically converted to a hash with a :on state and an empty :off state. When a +Hash+ is passed, the keys in the hash are the group's states, and the values are the CSS classes that will be applied when the state is used. Takes precedence over the +states+ argument.
      # @param states [Hash, nil] a hash of CSS classes that will be applied when the group is used. The keys in the hash are the group's states, and the values are the CSS classes that will be applied when the state is used.
      # @param default [Symbol, nil] the default state for the group. Must be one of the keys of the +states+ hash.
      # @param strategy [Symbol] determines how to handle the state hash when same +group+ key was already defined previously. Chose one of :merge, :replace, and :clear. The :merge strategy is equivalent to the default Ruby merge, e.g. if a state exists from a previous call and in the current call, the new state will overwrite the old state. The :replace strategy will replace the whole state hash, allowing you to reset the state hash. The :clear strategy will remove the style layer without replacement.
      #
      # @see #style_layer
      def style(group, state_or_states = nil, states: nil, default: nil, strategy: :merge)
        case state_or_states
        when Hash
          states = state_or_states
        when String
          states = {
            on: state_or_states,
            off: ""
          }
          default = :on
        else
          states ||= state_or_states
        end

        style_layer(group, states, default: default&.to_sym, strategy: strategy)
      end

      # Returns the default state key for a style layer.
      #
      # @param layer [Symbol] the name of the style layer.
      def default_layer_state(layer)
        __style_layers.dig(layer, :default).dup
      end

      # Returns the states of a style layer.
      #
      # @param layer [Symbol] the name of the style layer.
      def layer_states(layer)
        __style_layers.dig(layer, :states).dup
      end
    end

    # Returns the default state key for a style layer.
    #
    # @param layer [Symbol] the name of the style layer.
    def default_layer_state(layer)
      self.class.default_layer_state(layer)
    end

    # Returns a string of CSS classes based on the style layers and custom
    # classes passed in.
    #
    # === Usage
    #
    #   merge_layers(base: true, scheme: :gray, custom: "text-lg bg-white")
    #
    # This will combine the classes from:
    # - The :base layer with the :on state.
    # - The :scheme layer with the :gray state.
    # - The custom classes "text-lg bg-white".
    #
    # The resulting classes will be passed through TailwindMerge::Merger
    #
    # Be aware that the order in which you pass the style layers will affect
    # the end result. Conflicting classes in later style layers override the
    # classes in earlier style layers.
    #
    # === Boolean states and +nil+ values
    #
    # Boolean values are mapped to the :on and :off states in the style layer.
    # Layers with +nil+ value as state will be ignored.
    #
    # === Supplying custom classes
    #
    # Use the :custom "layer" with a css classes string as the last argument
    # to apply custom classes. This can be useful when you want to make small
    # modifications to the appearance of the component without having to define
    # a new style layer or a new state.
    #
    # === Undefined states
    # In production, when you specify an undefined state, the method will fall
    # back to the default state for the style layer. Unknown style layers
    # will be ignored.
    #
    # In other environments, when you specify an undefined state, the method
    # raises an error. Unknown style layers will also raise an error.
    #
    # @param custom_classes [String, nil] a string of CSS classes that take
    #   precedence over the style layers.
    # @param layers [Hash] a hash where the keys are the names of the style
    #   layers, and the values are the options keys for the style variant.
    #   Boolean values will be converted to :yes and :no option keys.
    #   +nil+ values will be ignored.
    # @return [String] a string of CSS classes.
    # @raise [ArgumentError] if an undefined option is specified in non-production environments.
    def merge_layers(**layers)
      layers.compact!
      validate_layers(layers) unless Rails.env.production?

      applied_classes = []

      layers.each do |layer, state|
        if layer.to_s.start_with?("custom")
          applied_classes << state.to_s
          next
        end

        state = normalize_layer_state(state)


        states = self.class.__style_layers.dig(layer, :states) || {}
        selected_classes = states[state] || states[default_layer_state(layer)]

        if selected_classes.nil? && !Rails.env.production?
          raise InvalidStyleDefinitionError,
                "Invalid option #{state.inspect} for style definition #{layer.inspect}"
        end

        applied_classes << selected_classes if selected_classes
      end

      MERGER.merge(applied_classes.compact)
    end
    alias styles merge_layers

    private

    def validate_layers(layers)
      layers.each do |layer, state|
        next if layer.to_s.start_with?("custom")

        unless self.class.__style_layers.include?(layer)
          raise InvalidStyleDefinitionError, <<~MSG
            Invalid style definition provided.

            Expected one of: #{self.class.__style_layers.keys.inspect}
            Got: #{layer.inspect}

            This will not raise in production, but will instead ignore the layer.
          MSG
        end

        state = normalize_layer_state(state)
        states = self.class.__style_layers.dig(layer, :states) || {}
        next if states.key?(state)

        raise InvalidStyleError, <<~MSG
          Invalid option provided for style definition #{layer.inspect}.

          Expected one of: #{states.keys.inspect}
          Got: #{state.inspect}

          This will not raise in production, but will instead fallback to: #{default_layer_state(layer).inspect}
        MSG
      end
    end

    def normalize_layer_state(value)
      return :on if value == true
      return :off if value == false
      value.to_sym
    end
  end
end
