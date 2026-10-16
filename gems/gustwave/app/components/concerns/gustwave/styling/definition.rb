# frozen_string_literal: true

module Gustwave
  module Styling
    # The styling of a component class: its superclass's definition with the
    # class's own declarations applied on top. Emits base and part classes
    # first, then those of variants and toggles, each in declaration order.
    #
    # Holds the classes only. The options that variants and toggles style,
    # with their values and defaults, are in the component's
    # Gustwave::Options::Definition.
    #
    # Built and checked by Styling on first use, and rebuilt after any
    # declaration on any class, so extensions of a parent class reach
    # subclasses that are already loaded.
    class Definition
      ROOT = :root

      Base = Struct.new(:classes, :unless, keyword_init: true)
      Part = Struct.new(:name, :classes, :unless, keyword_init: true)
      Variant = Struct.new(:name, :values, :unless, keyword_init: true)
      Toggle = Struct.new(:name, :on, :off, :per, :values, :unless, keyword_init: true)
      # The option values that skip the base styles, like an +unless:+ of the
      # base that a redeclared base keeps
      Unstyled = Struct.new(:unless, keyword_init: true)

      # The option kind each styled entry belongs to
      KINDS = { Variant => :variant, Toggle => :toggle }.freeze

      # Builds the definition of +component+ from +parent+ (a Definition or
      # nil) and the component's own +declarations+, then checks it against
      # the component's +options+.
      #
      # @raise [Gustwave::DefinitionError] if the result is inconsistent.
      def self.build(component, parent, declarations, options)
        definition = new(component, parent&.entries || {}, options)
        declarations.each { |action, args| definition.send(:apply, action, **args) }
        definition.send(:prune!)
        definition.send(:check!)
        definition.freeze
      end

      attr_reader :component, :entries, :options

      def initialize(component, entries, options)
        @component = component
        @entries = entries.dup
        @options = options
      end

      # Freezes the definition and computes what rendering looks up often.
      def freeze
        @entries.freeze
        @parts = parts.freeze
        @ordered = ordered.freeze
        super
      end

      # @return [Array<Symbol>] :root and every declared part.
      def parts
        @parts || [ ROOT, *@entries.values.grep(Part).map(&:name) ]
      end

      def part?(name)
        parts.include?(name)
      end

      # @param part [Symbol] :root or a declared part.
      # @param values [Hash{Symbol => Object}] a value for every option.
      # @return [Array<String>] the part's classes: base and part classes
      #   first, then those of variants and toggles, each in declaration order.
      def classes_for(part, values)
        ordered.filter_map do |entry|
          next if skipped?(entry, values)

          case entry
          when Base then entry.classes[part] unless unstyled?(values)
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
          variants: @entries.values.grep(Variant).map(&:name),
          toggles: @entries.values.grep(Toggle).map(&:name)
        }
      end

      private

      # The styled entries, base and parts before variants and toggles, so
      # variants and toggles win conflicts
      def ordered
        @ordered || @entries.values.grep_v(Unstyled).partition { |entry| !KINDS.key?(entry.class) }.flatten
      end

      def toggle_classes(entry, part, values)
        return entry.off[part] unless values[entry.name]
        return entry.on[part] unless entry.per

        entry.values.dig(values[entry.per], part)
      end

      def skipped?(entry, values)
        entry.unless.any? { |name, excluded| excluded.include?(values[name]) }
      end

      def unstyled?(values)
        unstyled = @entries[:unstyled]
        unstyled ? skipped?(unstyled, values) : false
      end

      def apply(action, name: nil, **args)
        case action
        when :base then @entries[:base] = Base.new(classes: args[:classes], unless: args.fetch(:unless) || {})
        when :unstyled then @entries[:unstyled] = Unstyled.new(unless: args.fetch(:unless))
        when :part then @entries[[ :part, name ]] = Part.new(name:, classes: args[:classes], unless: args.fetch(:unless) || {})
        when :remove_part then existing([ :part, name ], Part, "part #{name.inspect}") && @entries.delete([ :part, name ])
        when :variant then @entries[[ :option, name ]] = Variant.new(name:, values: args[:values], unless: args.fetch(:unless) || {})
        when :extend_variant then extend_variant(name, **args)
        when :toggle then @entries[[ :option, name ]] = Toggle.new(name:, unless: args.delete(:unless) || {}, **args)
        when :extend_toggle then extend_toggle(name, **args)
        end
      end

      def extend_variant(name, values:, unless:)
        variant = existing([ :option, name ], Variant, "variant #{name.inspect}")
        @entries[[ :option, name ]] = variant.dup.tap do |entry|
          entry.values = merge_values(variant.values, values)
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

      def existing(key, type, label)
        entry = @entries[key]
        return entry if entry.is_a?(type)

        raise DefinitionError.new(component, "#{label} isn't defined#{" (it's a #{entry.class.name.demodulize.downcase})" if entry}")
      end

      # Drops the classes of variants and toggles whose option was removed or
      # redeclared as another kind, e.g. a variant a subclass redeclared as a
      # plain option.
      def prune!
        @entries.delete_if do |_key, entry|
          kind = KINDS[entry.class]
          kind && options.option(entry.name)&.kind != kind
        end
      end

      def check!
        errors = @entries.each_value.flat_map { |entry| problems(entry) }
        raise DefinitionError.new(component, errors.join("\n")) if errors.any?
      end

      def problems(entry)
        errors = unless_problems(entry) + part_problems(entry)
        return errors unless entry.is_a?(Toggle) && entry.per

        errors + options.coverage_problems(label(entry), entry.values.keys, entry.per, "per", "classes")
      end

      def unless_problems(entry)
        entry.unless.flat_map do |name, excluded|
          option = options.option(name)
          condition = entry.is_a?(Unstyled) ? "#{name}:" : "unless: #{name.inspect}"
          next [ "#{label(entry)} has #{condition}, which isn't an option" ] unless option

          unknown = excluded - option.values
          unknown.any? ? [ "#{label(entry)} has #{condition} with unknown values #{unknown.inspect}" ] : []
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
        when Unstyled then "unstyled"
        else "#{entry.class.name.demodulize.downcase} #{entry.name.inspect}"
        end
      end
    end
  end
end
