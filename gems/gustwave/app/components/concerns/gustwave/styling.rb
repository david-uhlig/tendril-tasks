# frozen_string_literal: true

module Gustwave
  # Declares a component's CSS classes and computes them for the options a
  # caller picked.
  #
  # === Declaring styles
  #
  #   class Badge < Gustwave::Component
  #     base    "inline-flex items-center rounded-sm", unless: { scheme: :none }
  #     part    :icon, "h-3 w-auto"
  #
  #     variant :scheme, default: :gray, values: {
  #       gray: "bg-gray-100 text-gray-800",
  #       red:  "bg-red-100 text-red-800"
  #     }
  #     variant :size, default: :md, values: {
  #       sm: { root: "text-xs px-1.5", icon: "h-2.5" },
  #       md: "text-sm px-2"
  #     }
  #     toggle  :pill, "rounded-full"
  #     toggle  :border, per: :scheme, values: { gray: "ring-1 ring-gray-300", red: "ring-1 ring-red-300" }
  #   end
  #
  # * +base+ styles the root element, or several parts when given a hash.
  # * +part+ declares a named element besides the root, e.g. an icon slot,
  #   optionally with its own classes.
  # * +variant+ is an option with a fixed set of values and a +default:+.
  #   A variant without a +:none+ value gets one that adds no classes.
  # * +toggle+ is an on/off option, off by default. It can style both states
  #   (+on:+ / +off:+) or depend on a variant (+per:+).
  # * +lookup+ holds a value per value of a variant that isn't a class, e.g.
  #   the size to pass on to a child component. Read it with +style_lookup+.
  #
  #     lookup :icon_size, per: :size, values: { sm: :xs, md: :sm }
  #     style_lookup(:icon_size) # => :sm for size :md
  #
  # A plain string targets the root element, or the part named by +part:+. A
  # hash targets parts by name: <tt>{ root: "…", icon: "…" }</tt>. Every
  # declaration takes +unless:+ to skip it for some option values, e.g.
  # <tt>unless: { scheme: :none }</tt> or <tt>unless: { size: [:xs, :sm] }</tt>.
  #
  # Classes are emitted in declaration order, inherited declarations first,
  # and merged with TailwindMerge, so a later declaration wins a conflict.
  #
  # === Inheritance and extension
  #
  # Subclasses inherit every declaration. Declaring a name again replaces it
  # in place; nothing merges implicitly. To change an inherited declaration
  # partially, use +extend_base+, +extend_part+, +extend_variant+,
  # +extend_toggle+ or +extend_lookup+, which merge per value and per part.
  # +remove_part+, +remove_variant+, +remove_toggle+ and +remove_lookup+
  # delete one.
  #
  # Definitions are resolved on first use and again after any declaration, so
  # extending a parent class, e.g. from a Zeitwerk +on_load+ hook, reaches
  # subclasses that are already loaded:
  #
  #   Rails.autoloaders.main.on_load("Gustwave::Buttons::Base") do |base, _abspath|
  #     base.extend_variant :scheme, values: { brand: "bg-brand-600 text-white" }
  #   end
  #
  # A subclass that redefines the variant instead of extending it doesn't see
  # the extension. Mistakes such as an unknown part, a missing default or a
  # +per:+ toggle that doesn't cover every value raise a DefinitionError when
  # the definition is resolved, in every environment.
  #
  # So does a +per:+ toggle or lookup in a subclass that the extension leaves
  # without a value. Gustwave::Badge inherits the scheme above and styles its
  # border, outline, hover and dismiss button per scheme, so extend those in
  # the same hook:
  #
  #   Rails.autoloaders.main.on_load("Gustwave::Badge") do |badge, _abspath|
  #     badge.extend_toggle :border, values: { brand: "border border-brand-400" }
  #     badge.extend_toggle :outline, values: { brand: "outline outline-1 outline-brand-400" }
  #     badge.extend_toggle :hover, values: { brand: "hover:bg-brand-700" }
  #     badge.extend_lookup :dismiss_button_scheme, values: { brand: :base }
  #   end
  #
  # === Using styles in a component
  #
  # Accept style options as explicit keyword arguments and default them to
  # +DEFAULT+, which stands for the default declared in the DSL:
  #
  #   def initialize(text = nil, scheme: DEFAULT, size: DEFAULT, pill: false, **options)
  #     style_with(scheme:, size:, pill:)
  #     @options = attributes_for(options)
  #   end
  #
  # Only those keywords are style options, so +options+ keeps every HTML
  # attribute, even one named like an option. +attributes_for+ adds the
  # computed classes to +options+, merged with the caller's +class+. Callers
  # may pass +nil+ for an option to get its default, too.
  #
  # Unknown options or values raise outside production. In production an
  # unknown option is ignored and an unknown value falls back to the default.
  module Styling
    extend ActiveSupport::Concern

    # Default value for style keyword arguments: stands for the default that
    # the DSL declares, which a subclass or extension may change.
    DEFAULT = Object.new.tap do |default|
      def default.inspect = "DEFAULT"
      def default.to_s = "DEFAULT"
    end.freeze

    # Raised when a component's styling declarations are inconsistent.
    class DefinitionError < Gustwave::Error
      def initialize(component, message)
        super("Invalid styling for #{component}:\n#{message}")
      end
    end

    # Raised outside production for an option the component doesn't declare.
    class UnknownOptionError < Gustwave::Error
      def initialize(component, given:, expected:)
        super(Styling.suggest("#{component} has no style option #{given.inspect}", given, expected))
      end
    end

    # Raised outside production for a value a variant doesn't declare.
    class UnknownValueError < Gustwave::Error
      def initialize(component, option, given:, expected:, fallback:)
        message = Styling.suggest("Unknown value #{given.inspect} for #{option.inspect} of #{component}", given, expected)
        super("#{message}\nIn production, this falls back to #{fallback.inspect}.")
      end
    end

    # Raised outside production for a part the component doesn't declare.
    class UnknownPartError < Gustwave::Error
      def initialize(component, given:, expected:)
        super(Styling.suggest("#{component} has no part #{given.inspect}", given, expected))
      end
    end

    # Raised for a lookup the component doesn't declare.
    class UnknownLookupError < Gustwave::Error
      def initialize(component, given:, expected:)
        super(Styling.suggest("#{component} has no lookup #{given.inspect}", given, expected))
      end
    end

    @version = 0

    class << self
      # Bumped by every declaration, so cached definitions get rebuilt.
      attr_reader :version

      def changed!
        @version += 1
      end

      def strict?
        !Rails.env.production?
      end

      # Converts a variant value to a symbol: +2+ becomes +:"2"+.
      def normalize_value(value)
        value.is_a?(Symbol) ? value : value.to_s.to_sym
      end

      def suggest(message, given, expected)
        suggestion = DidYouMean::SpellChecker.new(dictionary: expected.map(&:to_s)).correct(given.to_s).first
        message += ". Did you mean #{suggestion.to_sym.inspect}?" if suggestion
        "#{message}\nExpected one of: #{expected.inspect}"
      end
    end

    class_methods do
      # Styles the root element, or several parts given as a hash.
      #
      #   base "inline-flex items-center", unless: { scheme: :none }
      #   base root: "relative", icon: "absolute"
      def base(classes = nil, **parts)
        options = parts.extract!(:unless)
        declare_styling(:base, classes: style_targets(classes || parts), unless: style_unless(options))
      end

      # Declares a part, an element besides the root, with optional classes.
      def part(name, classes = nil, **options)
        declare_styling(:part, name: name.to_sym, classes: classes, unless: style_unless(options))
      end

      # Declares a variant: an option with fixed values and a default.
      #
      #   variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
      #   variant :size, part: :icon, default: :md, values: { sm: "h-4", md: "h-5" }
      def variant(name, default:, values:, part: Definition::ROOT, **options)
        declare_styling(:variant, name: name.to_sym, default: Styling.normalize_value(default),
                                  values: style_values(values, part), unless: style_unless(options))
      end

      # Declares a toggle: an on/off option that is off by default.
      #
      #   toggle :pill, "rounded-full"
      #   toggle :visible, on: "opacity-100", off: "opacity-0"
      #   toggle :border, per: :size, values: { sm: "ring-1", md: "ring-2" }
      def toggle(name, classes = nil, on: nil, off: nil, per: nil, values: {}, part: Definition::ROOT, **options)
        declare_styling(:toggle, name: name.to_sym,
                                 on: style_targets(classes || on, part), off: style_targets(off, part),
                                 per: per&.to_sym, values: style_values(values, part), unless: style_unless(options))
      end

      # Merges classes into the inherited base, per part.
      def extend_base(classes = nil, **parts)
        options = parts.extract!(:unless)
        declare_styling(:extend_base, classes: style_targets(classes || parts), unless: style_unless(options, keep: true))
      end

      # Replaces an inherited part's classes or +unless:+.
      def extend_part(name, classes = nil, **options)
        declare_styling(:extend_part, name: name.to_sym, classes: classes, unless: style_unless(options, keep: true))
      end

      # Merges values into an inherited variant, per value and part, and
      # optionally changes its default.
      def extend_variant(name, default: nil, values: {}, part: Definition::ROOT, **options)
        declare_styling(:extend_variant, name: name.to_sym, default: default && Styling.normalize_value(default),
                                         values: style_values(values, part), unless: style_unless(options, keep: true))
      end

      # Merges classes into an inherited toggle, per state, value and part.
      def extend_toggle(name, classes = nil, on: nil, off: nil, values: {}, part: Definition::ROOT, **options)
        declare_styling(:extend_toggle, name: name.to_sym,
                                        on: style_targets(classes || on, part), off: style_targets(off, part),
                                        values: style_values(values, part), unless: style_unless(options, keep: true))
      end

      # Declares a lookup: a value per value of a variant, for anything that
      # isn't a class. Needs a value for every value of the variant; one for
      # an implicit +:none+ is optional.
      #
      #   lookup :icon_size, per: :size, values: { sm: :xs, md: :sm }
      def lookup(name, per:, values:)
        declare_styling(:lookup, name: name.to_sym, per: per.to_sym, values: lookup_values(values))
      end

      # Merges values into an inherited lookup, e.g. for values an extension
      # adds to its variant.
      def extend_lookup(name, values:)
        declare_styling(:extend_lookup, name: name.to_sym, values: lookup_values(values))
      end

      def remove_part(name)
        declare_styling(:remove_part, name: name.to_sym)
      end

      def remove_variant(name)
        declare_styling(:remove_variant, name: name.to_sym)
      end

      def remove_toggle(name)
        declare_styling(:remove_toggle, name: name.to_sym)
      end

      def remove_lookup(name)
        declare_styling(:remove_lookup, name: name.to_sym)
      end

      # Sets or returns the TailwindMerge instance that merges this
      # component's classes. Inherited by subclasses.
      def class_merger(merger = nil)
        return @class_merger = merger if merger

        @class_merger || (superclass.respond_to?(:class_merger) ? superclass.class_merger : TailwindHelper::MERGER)
      end

      # The resolved styling of this class, including inherited declarations.
      #
      # @return [Gustwave::Styling::Definition]
      # @raise [DefinitionError] if the declarations are inconsistent.
      def style_definition
        if @style_definition.nil? || @style_definition_version != Styling.version
          parent = superclass.style_definition if superclass.respond_to?(:style_definition)
          @style_definition = Definition.build(name || inspect, parent, @styling_declarations || [])
          @style_definition_version = Styling.version
        end
        @style_definition
      end

      # @return [Symbol] the default value of a variant.
      def variant_default(name)
        style_variant(name).default
      end

      # @return [Array<Symbol>] the values of a variant, including +:none+.
      def variant_values(name)
        style_variant(name).values.keys
      end

      private

      def declare_styling(action, **args)
        (@styling_declarations ||= []) << [ action, args ]
        Styling.changed!
        nil
      end

      def style_variant(name)
        style_definition.variant(name.to_sym) ||
          raise(UnknownOptionError.new(self.name || inspect, given: name, expected: style_definition.options.values.grep(Definition::Variant).map(&:name)))
      end

      # "classes" → { target => "classes" }, { root: …, icon: … } stays.
      def style_targets(classes, target = Definition::ROOT)
        case classes
        when nil then {}
        when Hash then classes.to_h { |part, value| [ part.to_sym, value.to_s ] }
        else { target.to_sym => classes.to_s }
        end
      end

      def style_values(values, target)
        values.to_h { |value, classes| [ Styling.normalize_value(value), style_targets(classes, target) ] }
      end

      def lookup_values(values)
        values.to_h { |value, result| [ Styling.normalize_value(value), result ] }.freeze
      end

      def style_unless(options, keep: false)
        options.assert_valid_keys(:unless)
        return nil if keep && !options.key?(:unless)

        (options[:unless] || {}).to_h do |name, values|
          [ name.to_sym, Array(values).map { |value| value == true || value == false ? value : Styling.normalize_value(value) } ]
        end
      end
    end

    # Selects style options for this instance. Merges with earlier calls.
    # +nil+ and +DEFAULT+ leave an option at its default.
    #
    #   style_with(scheme:, size:, pill:)
    def style_with(**selection)
      style_selection.merge!(normalize_style_selection(selection))
      self
    end

    # @return [Object] the value in effect for an option: the selected one or
    #   the default. +true+ or +false+ for a toggle.
    def style_value(name)
      values = style_values_for({})
      name = name.to_sym
      return values[name] if values.key?(name)

      raise UnknownOptionError.new(style_component_name, given: name, expected: values.keys)
    end

    # Returns a lookup's value for the value its variant has in effect, or
    # +nil+ for an implicit +:none+ the lookup doesn't cover. Options given
    # here override the selection for this call.
    #
    #   style_lookup(:icon_size)
    #   style_lookup(:icon_size, size: :sm)
    #
    # @raise [UnknownLookupError] if the component declares no such lookup.
    def style_lookup(name, **overrides)
      definition = self.class.style_definition
      lookup = definition.lookup(name.to_sym) ||
        raise(UnknownLookupError.new(style_component_name, given: name.to_sym, expected: definition.lookups.keys))

      lookup.values[style_values_for(overrides)[lookup.per]]
    end

    # Returns the classes of the root element or a part, or +nil+ if there are
    # none. Options given here override the selection for this call, and
    # +class:+ adds classes (a string or an array) that win conflicts.
    #
    #   classes                       # root element
    #   classes(:icon)                # a part
    #   classes(pill: true, class: "ms-2")
    def classes(part = Definition::ROOT, **overrides)
      extra = overrides.delete(:class)
      definition = self.class.style_definition
      part = part.to_sym

      unless definition.part?(part)
        raise UnknownPartError.new(style_component_name, given: part, expected: definition.parts) if Styling.strict?

        return merge_classes(extra)
      end

      merge_classes(definition.classes_for(part, style_values_for(overrides)), extra)
    end

    # Returns the HTML attributes +options+ with the classes of the root
    # element or a part, merged with +options[:class]+.
    #
    #   attributes_for(options)
    #   attributes_for(:icon, options, pill: true)
    def attributes_for(*args, **overrides)
      part = args.first.is_a?(Symbol) || args.first.is_a?(String) ? args.shift : Definition::ROOT
      attributes = (args.first || {}).to_h.symbolize_keys
      merged = classes(part, **overrides, class: attributes[:class])
      merged ? attributes.merge(class: merged) : attributes.except(:class)
    end

    # Merges class strings or arrays with the component's class merger.
    #
    # @return [String, nil]
    def merge_classes(*classes)
      self.class.class_merger.merge(classes.flatten.compact_blank).presence
    end

    # @see Gustwave::Styling::ClassMethods#variant_default
    def variant_default(name)
      self.class.variant_default(name)
    end

    private

    def style_component_name
      self.class.name || self.class.inspect
    end

    def style_selection
      @style_selection ||= {}
    end

    def style_values_for(overrides)
      self.class.style_definition.defaults.merge(style_selection, normalize_style_selection(overrides))
    end

    def normalize_style_selection(selection)
      definition = self.class.style_definition
      selection.each_with_object({}) do |(name, value), normalized|
        name = name.to_sym
        option = definition.option(name)
        unless option
          raise UnknownOptionError.new(style_component_name, given: name, expected: definition.options.keys) if Styling.strict?

          next
        end
        next if value.nil? || value.equal?(DEFAULT)

        if option.is_a?(Definition::Toggle)
          normalized[name] = ActiveModel::Type::Boolean.new.cast(value) || false
        else
          value = Styling.normalize_value(value)
          next normalized[name] = value if option.values.key?(value)
          raise UnknownValueError.new(style_component_name, name, given: value, expected: option.values.keys, fallback: option.default) if Styling.strict?
        end
      end
    end
  end
end
