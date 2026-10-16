# frozen_string_literal: true

module Gustwave
  module Options
    # The options of a component class: its superclass's definition with the
    # class's own declarations applied on top, in declaration order.
    #
    # Built and checked by Options on first use, and rebuilt after any
    # declaration on any class, so extensions of a parent class reach
    # subclasses that are already loaded.
    class Definition
      # An option and the declaration that made it: +:option+, or +:variant+
      # or +:toggle+ from Gustwave::Styling. Toggles are boolean, so their
      # values are +false+ and +true+. +implicit_none+ marks a +:none+ value
      # that was added for a variant, which derived values needn't cover.
      Option = Struct.new(:name, :kind, :default, :values, :implicit_none, keyword_init: true) do
        def boolean? = kind == :toggle
      end

      Derived = Struct.new(:name, :from, :values, keyword_init: true)

      # Builds the definition of +component+ from +parent+ (a Definition or
      # nil) and the component's own +declarations+, then checks it.
      #
      # @raise [Gustwave::DefinitionError] if the result is inconsistent.
      def self.build(component, parent, declarations)
        definition = new(component, parent&.entries || {})
        declarations.each { |action, args| definition.send(:apply, action, **args) }
        definition.send(:check!)
        definition.freeze
      end

      attr_reader :component, :entries

      def initialize(component, entries)
        @component = component
        @entries = entries.dup
      end

      # Freezes the definition and computes what rendering looks up often.
      def freeze
        @entries.freeze
        @options = options.freeze
        @defaults = defaults.freeze
        super
      end

      # @return [Hash{Symbol => Option}]
      def options
        @options || @entries.values.grep(Option).index_by(&:name)
      end

      def option(name)
        @entries[[ :option, name ]]
      end

      # @return [Option, nil] the option, unless it's a boolean toggle.
      def enum_option(name)
        entry = option(name)
        entry unless entry.nil? || entry.boolean?
      end

      def derived_values
        @entries.values.grep(Derived).index_by(&:name)
      end

      def derived(name)
        @entries[[ :derived, name ]]
      end

      # @return [Hash{Symbol => Object}] every option's default.
      def defaults
        @defaults || options.transform_values(&:default)
      end

      # Problems of a +per:+ or +from:+ relation of +label+ to the option
      # +name+: +values+ must cover each of its values, except an implicit
      # +:none+, and none it doesn't have.
      #
      # @return [Array<String>]
      def coverage_problems(label, values, name, relation, noun)
        option = enum_option(name)
        return [ "#{label} is #{relation} #{name.inspect}, which isn't a variant or option" ] unless option

        expected = option.values - (option.implicit_none ? [ :none ] : [])
        missing = expected - values
        unknown = values - option.values
        [
          ("#{label} has no #{noun} for #{name.inspect} #{missing.inspect}" if missing.any?),
          ("#{label} has #{noun} for unknown #{name.inspect} #{unknown.inspect}" if unknown.any?)
        ].compact
      end

      # A plain description of the definition, e.g. for docs and previews.
      def to_h
        {
          options: options.transform_values { |o| { kind: o.kind, default: o.default, values: o.values } },
          derived: derived_values.transform_values { |d| { from: d.from, values: d.values.keys } }
        }
      end

      private

      def apply(action, name:, **args)
        case action
        when :option then @entries[[ :option, name ]] = new_option(name, **args)
        when :extend_option then extend_option(name, **args)
        when :remove_option then existing_option(name, args[:kind]) && @entries.delete([ :option, name ])
        when :derive then @entries[[ :derived, name ]] = Derived.new(name:, **args)
        when :extend_derived then extend_derived(name, **args)
        when :remove_derived then existing_derived(name) && @entries.delete([ :derived, name ])
        end
      end

      def new_option(name, kind:, default:, values:, implicit_none: false)
        implicit_none &&= !values.include?(:none)
        values += [ :none ] if implicit_none
        Option.new(name:, kind:, default:, values:, implicit_none:)
      end

      def extend_option(name, kind:, default:, values:)
        option = existing_option(name, kind)
        @entries[[ :option, name ]] = option.dup.tap do |entry|
          entry.values = option.values | values
          entry.implicit_none = option.implicit_none && !values.include?(:none)
          entry.default = default unless default.nil?
        end
      end

      def extend_derived(name, values:)
        derived = existing_derived(name)
        @entries[[ :derived, name ]] = derived.dup.tap do |entry|
          entry.values = derived.values.merge(values).freeze
        end
      end

      # The option +name+, which must be a +kind+ one. A +nil+ kind takes any
      # option that isn't a toggle.
      def existing_option(name, kind)
        option = option(name)
        return option if option && (kind ? option.kind == kind : !option.boolean?)

        label = "#{kind || :option} #{name.inspect}"
        raise DefinitionError.new(component, "#{label} isn't defined#{" (it's #{article(option.kind)})" if option}")
      end

      def existing_derived(name)
        derived(name) || raise(DefinitionError.new(component, "derived #{name.inspect} isn't defined"))
      end

      def article(kind)
        "#{kind.to_s.start_with?(/[aeiou]/) ? "an" : "a"} #{kind}"
      end

      def check!
        errors = @entries.each_value.flat_map do |entry|
          case entry
          when Derived then coverage_problems("derived #{entry.name.inspect}", entry.values.keys, entry.from, "from", "values")
          when Option then default_problems(entry)
          end
        end
        raise DefinitionError.new(component, errors.join("\n")) if errors.any?
      end

      def default_problems(option)
        return [] if option.values.include?(option.default)

        [ "the default #{option.default.inspect} of #{option.kind} #{option.name.inspect} isn't one of its values " \
          "#{option.values.inspect}" ]
      end
    end
  end
end
