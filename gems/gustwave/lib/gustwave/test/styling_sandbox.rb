# frozen_string_literal: true

module Gustwave
  module Test
    # Restores the option and styling declarations of components after a
    # block, so a spec can extend a component the way an initializer or
    # +on_load+ hook does without leaking the change into other specs.
    #
    # @example spec/components/brand_color_spec.rb
    #   require "gustwave/test/styling_sandbox"
    #
    #   around do |example|
    #     Gustwave::Test::StylingSandbox.isolate(Gustwave::Buttons::Base) do
    #       Gustwave::Buttons::Base.extend_variant :color, values: { brand: "bg-brand-600" }
    #       example.run
    #     end
    #   end
    module StylingSandbox
      DECLARATIONS = %i[@option_declarations @styling_declarations].freeze

      # @param components [Array<Class>] components whose declarations to restore.
      def self.isolate(*components)
        saved = components.to_h do |component|
          [ component, DECLARATIONS.to_h { |name| [ name, component.instance_variable_get(name).dup ] } ]
        end
        yield
      ensure
        saved&.each do |component, declarations|
          declarations.each { |name, value| component.instance_variable_set(name, value) }
        end
        Gustwave::Options.changed!
      end
    end
  end
end
