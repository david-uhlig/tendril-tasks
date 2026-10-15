# frozen_string_literal: true

module Gustwave
  module Test
    # Restores the styling declarations of components after a block, so a
    # spec can extend a component the way an initializer or +on_load+ hook
    # does without leaking the change into other specs.
    #
    # @example spec/components/brand_scheme_spec.rb
    #   require "gustwave/test/styling_sandbox"
    #
    #   around do |example|
    #     Gustwave::Test::StylingSandbox.isolate(Gustwave::Buttons::Base) do
    #       Gustwave::Buttons::Base.extend_variant :scheme, values: { brand: "bg-brand-600" }
    #       example.run
    #     end
    #   end
    module StylingSandbox
      # @param components [Array<Class>] components whose declarations to restore.
      def self.isolate(*components)
        saved = components.to_h { |component| [ component, component.instance_variable_get(:@styling_declarations).dup ] }
        yield
      ensure
        saved&.each { |component, declarations| component.instance_variable_set(:@styling_declarations, declarations) }
        Gustwave::Styling.changed!
      end
    end
  end
end
