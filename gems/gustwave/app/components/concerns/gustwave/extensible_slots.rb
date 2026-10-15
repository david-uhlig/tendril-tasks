# frozen_string_literal: true

module Gustwave
  # Polymorphic slots that subclasses can extend with new types.
  #
  # ViewComponent's polymorphic slots (+renders_one :name, types: {...}+) are
  # closed: a subclass can neither add a type nor redeclare the slot. The
  # macros in this concern take the same +types:+ hash, but declare the slot
  # with a single lambda that dispatches to one private builder method per
  # type. Subclasses add or replace types through ordinary method overrides.
  #
  # === Declaring a slot
  #
  #   class Gustwave::Buttons::Base < Gustwave::Component
  #     renders_many_extensible :leading_visuals, types: {
  #       icon: ->(name, **options) { Gustwave::Icon.new(name, **options) },
  #       image: ->(src, **options) { image_tag src, **options }
  #     }
  #   end
  #
  # This defines, as with ViewComponent:
  # - +leading_visuals+ and +leading_visuals?+ to read the slot
  # - +with_leading_visual_icon+, +with_leading_visual_image+ (and their
  #   +_content+ variants) to set it
  #
  # and additionally:
  # - +with_leading_visual(type, ...)+ to set any type by name
  # - private +build_icon_leading_visual+ and +build_image_leading_visual+
  #   holding each type's lambda
  #
  # === Extending a slot in a subclass
  #
  #   class AvatarButton < Gustwave::Buttons::Default
  #     extend_slot :leading_visuals, types: {
  #       avatar: ->(src, **options) { Gustwave::Avatar.new(src, **options) }
  #     }
  #   end
  #
  #   button.with_leading_visual_avatar("me.png")
  #
  # Defining +build_avatar_leading_visual+ directly works too, but only
  # +extend_slot+ generates the +with_leading_visual_avatar+ setter.
  #
  # Types may be lambdas, component classes or class names, or a hash with
  # +renders:+ and +as:+ to rename the setter, as with ViewComponent. Component
  # classes receive the slot's block as their content, not as a constructor
  # block.
  module ExtensibleSlots
    extend ActiveSupport::Concern

    # Raised when a slot is set with a type that has no builder
    class UnknownSlotTypeError < Gustwave::Error; end

    # Raised when +extend_slot+ names a slot not declared as extensible
    class NotExtensibleSlotError < Gustwave::Error; end

    included do
      # Extensible slots, keyed by slot name, with +collection+ and the
      # registered +types+.
      class_attribute :extensible_slots,
                      instance_writer: false,
                      instance_predicate: false,
                      default: {}
    end

    class_methods do
      # Declares an extensible polymorphic +renders_one+ slot.
      #
      # @param slot_name [Symbol] the slot name.
      # @param types [Hash] the slot types, as for ViewComponent's +types:+.
      def renders_one_extensible(slot_name, types:)
        __gustwave_renders_extensible(slot_name, types:, collection: false)
      end

      # Declares an extensible polymorphic +renders_many+ slot.
      #
      # @param slot_name [Symbol] the plural slot name.
      # @param types [Hash] the slot types, as for ViewComponent's +types:+.
      def renders_many_extensible(slot_name, types:)
        __gustwave_renders_extensible(slot_name, types:, collection: true)
      end

      # Adds types to, or replaces types of, an inherited extensible slot.
      #
      # @param slot_name [Symbol] the slot name.
      # @param types [Hash] the slot types, as for ViewComponent's +types:+.
      def extend_slot(slot_name, types:)
        unless extensible_slots.key?(slot_name)
          raise NotExtensibleSlotError, "#{name} has no extensible slot #{slot_name.inspect}"
        end

        __gustwave_define_slot_types(slot_name, types)
      end

      # @return [String] the builder method name for a slot type.
      def slot_builder_name(slot_name, type)
        :"build_#{type}_#{__gustwave_slot_singular(slot_name)}"
      end

      private

      def __gustwave_renders_extensible(slot_name, types:, collection:)
        self.extensible_slots = extensible_slots.merge(slot_name => { collection:, types: [] })

        dispatcher = ->(type, *args, **options, &block) {
          __gustwave_build_slot(slot_name, type, *args, **options, &block)
        }
        collection ? renders_many(slot_name, dispatcher) : renders_one(slot_name, dispatcher)

        __gustwave_define_slot_types(slot_name, types)
      end

      def __gustwave_define_slot_types(slot_name, types)
        singular = __gustwave_slot_singular(slot_name)

        types.each do |type, renderable|
          setter_name = nil
          renderable, setter_name = renderable.values_at(:renders, :as) if renderable.is_a?(Hash)
          setter_name = :"with_#{setter_name || "#{singular}_#{type}"}"

          builder_name = slot_builder_name(slot_name, type)
          define_method(builder_name, __gustwave_builder(renderable))
          private builder_name

          define_method(setter_name) do |*args, **options, &block|
            public_send(:"with_#{singular}", type, *args, **options, &block)
          end

          define_method(:"#{setter_name}_content") do |content|
            public_send(setter_name) { content.to_s }

            self
          end
        end

        slot = extensible_slots[slot_name]
        self.extensible_slots = extensible_slots.merge(
          slot_name => slot.merge(types: slot[:types] | types.keys)
        )
      end

      # Matches ViewComponent: component classes are instantiated with the
      # slot's arguments, and the slot's block becomes their content.
      def __gustwave_builder(renderable)
        case renderable
        when Proc
          renderable
        when Class
          ->(*args, **options) { renderable.new(*args, **options) }
        when String
          ->(*args, **options) { self.class.const_get(renderable).new(*args, **options) }
        else
          raise ArgumentError, "slot type must be a lambda, class or class name, got #{renderable.inspect}"
        end
      end

      def __gustwave_slot_singular(slot_name)
        if extensible_slots.dig(slot_name, :collection)
          ActiveSupport::Inflector.singularize(slot_name)
        else
          slot_name
        end
      end
    end

    private

    def __gustwave_build_slot(slot_name, type, ...)
      __gustwave_guard_single_set(slot_name)

      builder_name = self.class.slot_builder_name(slot_name, type)
      unless respond_to?(builder_name, true)
        known = extensible_slots[slot_name][:types].map(&:inspect).join(", ")
        raise UnknownSlotTypeError,
              "#{self.class.name} slot #{slot_name.inspect} has no type #{type.inspect} (known: #{known})"
      end

      send(builder_name, ...)
    end

    # ViewComponent raises when a polymorphic +renders_one+ slot is set twice;
    # a plain lambda slot would silently replace it instead.
    def __gustwave_guard_single_set(slot_name)
      return if extensible_slots[slot_name][:collection]

      @__gustwave_set_slots ||= Set.new
      unless @__gustwave_set_slots.add?(slot_name)
        raise ViewComponent::ContentAlreadySetForPolymorphicSlotError.new(slot_name)
      end
    end
  end
end
