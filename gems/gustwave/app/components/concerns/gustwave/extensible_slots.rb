# frozen_string_literal: true

module Gustwave
  # Slots that subclasses can extend or override.
  #
  # ViewComponent's slots are closed: a subclass can neither add a type to a
  # polymorphic slot (+renders_one :name, types: {...}+) nor change what a
  # lambda or component slot builds, and redeclaring the slot raises. The
  # macros in this concern take the same arguments, but declare the slot with
  # a single lambda that dispatches to a private builder method. Subclasses
  # add or replace types through ordinary method overrides.
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
  # - private +build_slot_leading_visual_icon+ and +build_slot_leading_visual_image+
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
  # Defining +build_slot_leading_visual_avatar+ directly works too, but only
  # +extend_slot+ generates the +with_leading_visual_avatar+ setter.
  #
  # To extend a Gustwave component itself, and with it every subclass, call
  # +extend_slot+ whenever the component loads. A one-off call in an
  # initializer is lost on the first code reload:
  #
  #   # config/initializers/gustwave.rb
  #   Rails.autoloaders.main.on_load("Gustwave::Buttons::Base") do |base, _abspath|
  #     base.extend_slot :leading_visuals, types: { ... }
  #   end
  #
  # === Accepting any component
  #
  # Pass +renderable:+ to add a +renderable+ type that accepts any component
  # instead of a fixed list. The option names a parent method returning the
  # slot context; components that implement +apply_slot_context+ receive it,
  # others render unchanged.
  #
  #   renders_many_extensible :leading_visuals, types: {...}, renderable: :visual_context
  #
  #   class MyAvatar < Gustwave::Component
  #     def apply_slot_context(slot:, size:, **)
  #       @size = size
  #     end
  #   end
  #
  #   button.with_leading_visual_renderable(MyAvatar.new("me.png"))
  #
  # === Single-type slots
  #
  # Pass a lambda, component class or class name instead of +types:+ for a
  # slot with a single type. The setters are ViewComponent's, and the builder
  # is named after the slot alone:
  #
  #   class Gustwave::Indicator < Gustwave::Component
  #     renders_one_extensible :legend, ->(text = nil, **options) { ... }
  #   end
  #
  #   indicator.with_legend("New")
  #
  # Override the private +build_slot_legend+ in a subclass to wrap it, or
  # pass +extend_slot+ a new lambda to replace it:
  #
  #   class BoldIndicator < Gustwave::Indicator
  #     private
  #
  #     def build_slot_legend(text = nil, **options, &block)
  #       super(text, class: "font-bold", **options, &block)
  #     end
  #   end
  #
  #   class BadgeIndicator < Gustwave::Indicator
  #     extend_slot :legend, ->(text) { Gustwave::Badge.new(text) }
  #   end
  #
  # Unlike polymorphic slots, setting a single-type +renders_one+ slot twice
  # replaces the first value, as with ViewComponent.
  #
  # Types may be lambdas, component classes or class names, or a hash with
  # +renders:+ and +as:+ to rename the setter, as with ViewComponent. Component
  # classes receive the slot's block as their content, not as a constructor
  # block.
  module ExtensibleSlots
    extend ActiveSupport::Concern

    # Base error class for extensible slot exceptions
    class Error < StandardError; end

    # Raised when a slot is set with a type that has no builder
    class UnknownSlotTypeError < Error; end

    # Raised when +extend_slot+ names a slot not declared as extensible
    class NotExtensibleSlotError < Error; end

    included do
      # Extensible slots, keyed by slot name, with +collection+ and, for
      # polymorphic slots, the registered +types+.
      class_attribute :extensible_slots,
                      instance_writer: false,
                      instance_predicate: false,
                      default: {}
    end

    class_methods do
      # Declares an extensible +renders_one+ slot, either with a single
      # +callable+ or polymorphic with +types:+.
      #
      # @param slot_name [Symbol] the slot name.
      # @param callable [Proc, Class, String, nil] the slot's lambda, component class or class name, as for ViewComponent.
      # @param types [Hash, nil] the slot types, as for ViewComponent's +types:+.
      # @param renderable [Symbol, true, nil] adds a +renderable+ type accepting any component. A symbol names the parent method returning the slot context; +true+ passes no context. Polymorphic slots only.
      def renders_one_extensible(slot_name, callable = nil, types: nil, renderable: nil)
        __gustwave_renders_extensible(slot_name, callable, types:, renderable:, collection: false)
      end

      # Declares an extensible +renders_many+ slot, either with a single
      # +callable+ or polymorphic with +types:+.
      #
      # @param slot_name [Symbol] the plural slot name.
      # @param callable [Proc, Class, String, nil] the slot's lambda, component class or class name, as for ViewComponent.
      # @param types [Hash, nil] the slot types, as for ViewComponent's +types:+.
      # @param renderable [Symbol, true, nil] adds a +renderable+ type accepting any component. A symbol names the parent method returning the slot context; +true+ passes no context. Polymorphic slots only.
      def renders_many_extensible(slot_name, callable = nil, types: nil, renderable: nil)
        __gustwave_renders_extensible(slot_name, callable, types:, renderable:, collection: true)
      end

      # Replaces the builder of an inherited single-type slot, or adds types
      # to, or replaces types of, an inherited polymorphic slot.
      #
      # @param slot_name [Symbol] the slot name.
      # @param callable [Proc, Class, String, nil] the new lambda, component class or class name of a single-type slot.
      # @param types [Hash, nil] the types of a polymorphic slot, as for ViewComponent's +types:+.
      def extend_slot(slot_name, callable = nil, types: nil)
        unless extensible_slots.key?(slot_name)
          raise NotExtensibleSlotError, "#{name} has no extensible slot #{slot_name.inspect}"
        end

        if extensible_slots[slot_name].key?(:types)
          if callable || types.nil?
            raise ArgumentError, "#{name} slot #{slot_name.inspect} is polymorphic, pass types: to extend it"
          end

          __gustwave_define_slot_types(slot_name, types)
        else
          if types || callable.nil?
            raise ArgumentError, "#{name} slot #{slot_name.inspect} has a single type, pass a callable to replace it"
          end

          __gustwave_define_builder(slot_builder_name(slot_name), callable)
        end
      end

      # The +build_slot_+ prefix keeps builders apart from ordinary helpers
      # such as +build_options+, which would otherwise silently replace the
      # builder of an +options+ slot.
      #
      # @return [String] the builder method name for a slot type, or for a
      #   single-type slot if +type+ is +nil+.
      def slot_builder_name(slot_name, type = nil)
        singular = __gustwave_slot_singular(slot_name)
        type ? :"build_slot_#{singular}_#{type}" : :"build_slot_#{singular}"
      end

      private

      def __gustwave_renders_extensible(slot_name, callable, types:, renderable:, collection:)
        if callable.nil? == types.nil?
          raise ArgumentError, "#{name} slot #{slot_name.inspect} needs either a callable or types:"
        end

        if callable
          __gustwave_renders_single(slot_name, callable, renderable:, collection:)
        else
          __gustwave_renders_polymorphic(slot_name, types:, renderable:, collection:)
        end
      end

      def __gustwave_renders_single(slot_name, callable, renderable:, collection:)
        if renderable
          raise ArgumentError, "#{name} slot #{slot_name.inspect} has a single type, renderable: needs types:"
        end

        self.extensible_slots = extensible_slots.merge(slot_name => { collection: })
        builder_name = slot_builder_name(slot_name)

        # Dispatch at call time, so subclass overrides of the builder apply.
        dispatcher = ->(*args, **options, &block) { send(builder_name, *args, **options, &block) }
        collection ? renders_many(slot_name, dispatcher) : renders_one(slot_name, dispatcher)

        __gustwave_define_builder(builder_name, callable)
      end

      def __gustwave_renders_polymorphic(slot_name, types:, renderable:, collection:)
        self.extensible_slots = extensible_slots.merge(slot_name => { collection:, types: [] })

        dispatcher = ->(type, *args, **options, &block) {
          __gustwave_build_slot(slot_name, type, *args, **options, &block)
        }
        collection ? renders_many(slot_name, dispatcher) : renders_one(slot_name, dispatcher)

        __gustwave_define_slot_types(slot_name, types)
        __gustwave_define_renderable_type(slot_name, renderable) if renderable
      end

      def __gustwave_define_renderable_type(slot_name, context_method)
        context_method = nil if context_method == true

        __gustwave_define_slot_types(slot_name, renderable: ->(component) {
          __gustwave_apply_slot_context(slot_name, component, context_method)
        })
      end

      def __gustwave_define_slot_types(slot_name, types)
        singular = __gustwave_slot_singular(slot_name)

        types.each do |type, renderable|
          setter_name = nil
          renderable, setter_name = renderable.values_at(:renders, :as) if renderable.is_a?(Hash)
          if setter_name&.to_sym == singular.to_sym
            raise ArgumentError,
                  "#{name} slot #{slot_name.inspect} type #{type.inspect} can't use as: #{setter_name.inspect}, which is the slot's own setter"
          end

          setter_name = :"with_#{setter_name || "#{singular}_#{type}"}"

          __gustwave_define_builder(slot_builder_name(slot_name, type), renderable)

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

      def __gustwave_define_builder(builder_name, renderable)
        define_method(builder_name, __gustwave_builder(renderable))
        private builder_name
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

      send(builder_name, ...).tap { __gustwave_mark_slot_set(slot_name) }
    end

    def __gustwave_apply_slot_context(slot_name, component, context_method)
      unless component.respond_to?(:render_in)
        raise ArgumentError, "#{self.class.name} slot #{slot_name.inspect} expects a renderable, got #{component.inspect}"
      end

      if component.respond_to?(:apply_slot_context)
        context = context_method ? send(context_method) : {}
        component.apply_slot_context(slot: slot_name, **context)
      end

      component
    end

    # ViewComponent raises when a polymorphic +renders_one+ slot is set twice;
    # a plain lambda slot would silently replace it instead.
    #
    # The slot only counts as set once its builder succeeded, so a failed
    # attempt can be retried. The flag is never reset: ViewComponent raises
    # +ReusedInstanceError+ before a component instance renders twice.
    def __gustwave_guard_single_set(slot_name)
      return if extensible_slots[slot_name][:collection]
      return unless defined?(@__gustwave_set_slots) && @__gustwave_set_slots.include?(slot_name)

      raise ViewComponent::ContentAlreadySetForPolymorphicSlotError.new(slot_name)
    end

    def __gustwave_mark_slot_set(slot_name)
      return if extensible_slots[slot_name][:collection]

      (@__gustwave_set_slots ||= Set.new) << slot_name
    end
  end
end
