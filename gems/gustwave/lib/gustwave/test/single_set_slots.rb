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
      class SlotAlreadySetError < StandardError
        def initialize(component_name, slot_name)
          super("#{component_name} already has the renders_one slot `#{slot_name}` set. Setting it again would silently replace the first value.")
        end
      end

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
