# frozen_string_literal: true

module Gustwave
  module Test
    # Raises when a +renders_one+ slot is set more than once on the same
    # component instance.
    #
    # ViewComponent silently replaces the earlier value of a plain
    # +renders_one+ slot, while a polymorphic one raises
    # +ViewComponent::ContentAlreadySetForPolymorphicSlotError+. Prepending this
    # module in specs makes plain slots fail loudly, too.
    #
    # @example spec/rails_helper.rb
    #   require "gustwave/test/single_set_slots"
    #   ViewComponent::Base.prepend(Gustwave::Test::SingleSetSlots)
    module SingleSetSlots
      # Raised by SingleSetSlots when a +renders_one+ slot that already has a value is set again.
      class SlotAlreadySetError < StandardError
        # @param component_name [String] the class name of the component.
        # @param slot_name [Symbol] the slot that is already set.
        def initialize(component_name, slot_name)
          super("#{component_name} already has the renders_one slot `#{slot_name}` set. Setting it again would silently replace the first value.")
        end
      end

      # Raises SlotAlreadySetError when a plain +renders_one+ slot already has a value, and
      # otherwise sets the slot as ViewComponent does.
      #
      # @param slot_name [Symbol] the slot being set.
      # @return [ViewComponent::Slot] the slot that was set.
      def __vc_set_slot(slot_name, *, **, &)
        if !self.class.registered_slots.dig(slot_name, :collection) &&
            defined?(@__vc_set_slots) && @__vc_set_slots&.key?(slot_name)
          raise SlotAlreadySetError.new(self.class.name, slot_name)
        end

        super
      end
    end
  end
end
