# frozen_string_literal: true

module Gustwave
  module Styling
    # The styling of a component class: its superclass's definition with the
    # class's own declarations applied on top, in declaration order.
    #
    # Built and checked by Styling on first use, and rebuilt after any
    # declaration on any class, so extensions of a parent class reach
    # subclasses that are already loaded.
    class Definition
      ROOT = :root

      Base = Struct.new(:classes, :unless, keyword_init: true)
      Part = Struct.new(:name, :classes, :unless, keyword_init: true)
      Variant = Struct.new(:name, :default, :values, :implicit_none, :unless, keyword_init: true)
      Toggle = Struct.new(:name, :on, :off, :per, :values, :unless, keyword_init: true)

      # Builds the definition of +component+ from +parent+ (a Definition or
      # nil) and the component's own +declarations+, then checks it.
      #
      # @raise [DefinitionError] if the result is inconsistent.
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
        @parts = parts.freeze
        @options = options.freeze
        @defaults = defaults.freeze
        super
      end

      # @return [Array<Symbol>] :root and every declared part.
      def parts
        @parts || [ ROOT, *@entries.values.grep(Part).map(&:name) ]
      end

      def part?(name)
        parts.include?(name)
      end

      def options
        @options || @entries.values.select { |entry| entry.is_a?(Variant) || entry.is_a?(Toggle) }.index_by(&:name)
      end

      def option(name)
        @entries[[ :option, name ]]
      end

      def variant(name)
        entry = option(name)
        entry if entry.is_a?(Variant)
      end

      # @return [Hash{Symbol => Object}] every option's default: a variant's
      #   default value, or +false+ for a toggle.
      def defaults
        @defaults || options.transform_values { |entry| entry.is_a?(Variant) ? entry.default : false }
      end

      # @param part [Symbol] :root or a declared part.
      # @param values [Hash{Symbol => Object}] a value for every option.
      # @return [Array<String>] the part's classes in declaration order.
      def classes_for(part, values)
        @entries.each_value.filter_map do |entry|
          next if skipped?(entry, values)

          case entry
          when Base then entry.classes[part]
          when Part then entry.classes if entry.name == part
          when Variant then entry.values.dig(values[entry.name], part)
          when Toggle then toggle_classes(entry, part, values)
          end
        end
      end

      # A plain description of the definition, e.g. for docs and previews.
      def to_h
        {
          parts: parts,
          variants: options.values.grep(Variant).to_h { |v| [ v.name, { default: v.default, values: v.values.keys } ] },
          toggles: options.values.grep(Toggle).map(&:name)
        }
      end

      private

      def toggle_classes(entry, part, values)
        return entry.off[part] unless values[entry.name]
        return entry.on[part] unless entry.per

        entry.values.dig(values[entry.per], part)
      end

      def skipped?(entry, values)
        entry.unless.any? { |name, excluded| excluded.include?(values[name]) }
      end

      def apply(action, name: nil, **args)
        case action
        when :base then @entries[:base] = Base.new(classes: args[:classes], unless: args.fetch(:unless) || {})
        when :extend_base then extend_base(**args)
        when :part then @entries[[ :part, name ]] = Part.new(name:, classes: args[:classes], unless: args.fetch(:unless) || {})
        when :extend_part then extend_part(name, **args)
        when :variant then @entries[[ :option, name ]] = new_variant(name, **args)
        when :extend_variant then extend_variant(name, **args)
        when :toggle then @entries[[ :option, name ]] = Toggle.new(name:, unless: args.delete(:unless) || {}, **args)
        when :extend_toggle then extend_toggle(name, **args)
        when :remove_part then remove(:part, name, Part)
        when :remove_variant then remove(:option, name, Variant)
        when :remove_toggle then remove(:option, name, Toggle)
        end
      end

      def new_variant(name, default:, values:, unless:)
        implicit_none = !values.key?(:none)
        values = values.merge(none: {}) if implicit_none
        Variant.new(name:, default:, values:, implicit_none:, unless: binding.local_variable_get(:unless) || {})
      end

      def extend_base(classes:, unless:)
        base = existing(:base, Base, "base")
        @entries[:base] = base.dup.tap do |entry|
          entry.classes = base.classes.merge(classes)
          entry.unless = binding.local_variable_get(:unless) || base.unless
        end
      end

      def extend_part(name, classes:, unless:)
        part = existing([ :part, name ], Part, "part #{name.inspect}")
        @entries[[ :part, name ]] = part.dup.tap do |entry|
          entry.classes = classes unless classes.nil?
          entry.unless = binding.local_variable_get(:unless) || part.unless
        end
      end

      def extend_variant(name, default:, values:, unless:)
        variant = existing([ :option, name ], Variant, "variant #{name.inspect}")
        @entries[[ :option, name ]] = variant.dup.tap do |entry|
          entry.values = merge_values(variant.values, values)
          entry.implicit_none = variant.implicit_none && !values.key?(:none)
          entry.default = default unless default.nil?
          entry.unless = binding.local_variable_get(:unless) || variant.unless
        end
      end

      def extend_toggle(name, on:, off:, values:, unless:)
        toggle = existing([ :option, name ], Toggle, "toggle #{name.inspect}")
        @entries[[ :option, name ]] = toggle.dup.tap do |entry|
          entry.on = toggle.on.merge(on)
          entry.off = toggle.off.merge(off)
          entry.values = merge_values(toggle.values, values)
          entry.unless = binding.local_variable_get(:unless) || toggle.unless
        end
      end

      def merge_values(old, new)
        old.merge(new) { |_value, old_parts, new_parts| old_parts.merge(new_parts) }
      end

      def remove(kind, name, type)
        existing([ kind, name ], type, "#{type.name.demodulize.downcase} #{name.inspect}")
        @entries.delete([ kind, name ])
      end

      def existing(key, type, label)
        entry = @entries[key]
        return entry if entry.is_a?(type)

        raise DefinitionError.new(component, "#{label} isn't defined#{" (it's a #{entry.class.name.demodulize.downcase})" if entry}")
      end

      def check!
        errors = @entries.each_value.flat_map { |entry| problems(entry) }
        raise DefinitionError.new(component, errors.join("\n")) if errors.any?
      end

      def problems(entry)
        errors = unless_problems(entry) + part_problems(entry)
        case entry
        when Variant then errors + variant_problems(entry)
        when Toggle then errors + toggle_problems(entry)
        else errors
        end
      end

      def variant_problems(variant)
        return [] if variant.values.key?(variant.default)

        [ "the default #{variant.default.inspect} of variant #{variant.name.inspect} isn't one of its values " \
          "#{variant.values.keys.inspect}" ]
      end

      def toggle_problems(toggle)
        return [] unless toggle.per

        variant = variant(toggle.per)
        return [ "toggle #{toggle.name.inspect} is per #{toggle.per.inspect}, which isn't a variant" ] unless variant

        expected = variant.values.keys - (variant.implicit_none ? [ :none ] : [])
        missing = expected - toggle.values.keys
        unknown = toggle.values.keys - variant.values.keys
        [
          ("toggle #{toggle.name.inspect} has no classes for #{toggle.per.inspect} #{missing.inspect}" if missing.any?),
          ("toggle #{toggle.name.inspect} has classes for unknown #{toggle.per.inspect} #{unknown.inspect}" if unknown.any?)
        ].compact
      end

      def unless_problems(entry)
        entry.unless.flat_map do |name, excluded|
          option = option(name)
          next [ "#{label(entry)} has unless: #{name.inspect}, which isn't a variant or toggle" ] unless option

          allowed = option.is_a?(Variant) ? option.values.keys : [ true, false ]
          unknown = excluded - allowed
          unknown.any? ? [ "#{label(entry)} has unless: #{name.inspect} with unknown values #{unknown.inspect}" ] : []
        end
      end

      def part_problems(entry)
        targets = case entry
        when Base then entry.classes.keys
        when Variant then entry.values.values.flat_map(&:keys)
        when Toggle then entry.on.keys + entry.off.keys + entry.values.values.flat_map(&:keys)
        else []
        end
        unknown = targets.uniq - parts
        unknown.any? ? [ "#{label(entry)} styles unknown parts #{unknown.inspect}" ] : []
      end

      def label(entry)
        case entry
        when Base then "base"
        else "#{entry.class.name.demodulize.downcase} #{entry.name.inspect}"
        end
      end
    end
  end
end
