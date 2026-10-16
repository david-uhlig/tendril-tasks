# frozen_string_literal: true

module Gustwave
  # Declares a component's options, the values a caller picks from a fixed
  # list, and the values derived from them. Gustwave::Styling builds on it to
  # add CSS classes to options.
  #
  # === Declaring options
  #
  #   class Heading < Gustwave::Component
  #     option :tag, default: :h2, values: %i[h1 h2 h3]
  #     derive :font_size, from: :tag, values: { h1: :xl, h2: :lg, h3: :md }
  #   end
  #
  # * +option+ is a value from a fixed list, with a +default:+, e.g. an HTML
  #   tag. Read it with +option_value+.
  # * +derive+ derives a value from an option for each of its values, e.g.
  #   the size to pass on to a child component. Read it with +derived_value+.
  #
  #     derived_value(:font_size) # => :lg for tag :h2
  #
  # Gustwave::Styling's +variant+ and +toggle+ declare options, too: a variant
  # is an option with classes per value, a toggle a boolean option with
  # classes. Read and derive from them the same way.
  #
  # === Inheritance and extension
  #
  # Subclasses inherit every declaration. Declaring a name again replaces it
  # in place. +extend_option+ adds values to an inherited option and may
  # change its default; +extend_derived+ adds values to a derived value.
  # +remove_option+ and +remove_derived+ delete one.
  #
  # Definitions are resolved on first use and again after any declaration, so
  # extending a parent class, e.g. from a Zeitwerk +on_load+ hook, reaches
  # subclasses that are already loaded. A derived value that an extension of
  # its option leaves without a value raises a Gustwave::DefinitionError when
  # the definition is resolved, in every environment, so extend both in the
  # same hook:
  #
  #   Rails.autoloaders.main.on_load("Gustwave::Badge") do |badge, _abspath|
  #     badge.extend_variant :scheme, values: { brand: "bg-brand-600 text-white" }
  #     badge.extend_derived :dismiss_button_scheme, values: { brand: :base }
  #   end
  #
  # === Using options in a component
  #
  # Accept options as explicit keyword arguments and default them to
  # +DEFAULT+, which stands for the default declared in the DSL:
  #
  #   def initialize(text = nil, tag: DEFAULT, scheme: DEFAULT, pill: false, **options)
  #     select_options(tag:, scheme:, pill:)
  #     @tag = option_value(:tag)
  #   end
  #
  # Only those keywords are options, so +options+ keeps every HTML attribute,
  # even one named like an option. Callers may pass +nil+ for an option to get
  # its default, too.
  #
  # Unknown options or values raise when Gustwave.strict?, by default outside
  # production. Otherwise an unknown option is ignored and an unknown value
  # falls back to the default.
  module Options
    extend ActiveSupport::Concern

    # Default value for option keyword arguments: stands for the default that
    # the DSL declares, which a subclass or extension may change.
    DEFAULT = Object.new.tap do |default|
      def default.inspect = "DEFAULT"
      def default.to_s = "DEFAULT"
    end.freeze

    # Raised when Gustwave.strict? for an option the component doesn't
    # declare.
    class UnknownOptionError < Gustwave::Error
      def initialize(component, given:, expected:)
        super(Options.suggest("#{component} has no option #{given.inspect}", given, expected))
      end
    end

    # Raised when Gustwave.strict? for a value an option doesn't declare.
    class UnknownValueError < Gustwave::Error
      def initialize(component, option, given:, expected:, fallback:)
        message = Options.suggest("Unknown value #{given.inspect} for #{option.inspect} of #{component}", given, expected)
        super("#{message}\n#{Options.fallback_note(fallback)}")
      end
    end

    # Raised for a derived value the component doesn't declare.
    class UnknownDerivedValueError < Gustwave::Error
      def initialize(component, given:, expected:)
        super(Options.suggest("#{component} has no derived value #{given.inspect}", given, expected))
      end
    end

    @version = 0

    class << self
      # Bumped by every declaration of options or styles, so cached
      # definitions get rebuilt.
      attr_reader :version

      def changed!
        @version += 1
      end

      # Tells what a component falls back to when Gustwave isn't strict.
      def fallback_note(fallback)
        "When Gustwave isn't strict, e.g. in production, this falls back to #{fallback.inspect}."
      end

      # Converts an option value to a symbol: +2+ becomes +:"2"+.
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
      # Declares an option: a value from a fixed list, with a default.
      #
      #   option :tag, default: :h2, values: %i[h1 h2 h3]
      def option(name, default:, values:)
        declare_option(:option, name:, kind: :option, default: Options.normalize_value(default),
                                values: normalize_option_values(values))
      end

      # Adds values to an inherited option, and optionally changes its
      # default.
      def extend_option(name, default: nil, values: [])
        declare_option(:extend_option, name:, kind: nil, default: default && Options.normalize_value(default),
                                       values: normalize_option_values(values))
      end

      def remove_option(name)
        declare_option(:remove_option, name:, kind: :option)
      end

      # Derives a value from an option, for anything that isn't the option's
      # value itself. Needs a value for every value of the option; one for a
      # variant's implicit +:none+ is optional.
      #
      #   derive :icon_size, from: :size, values: { sm: :xs, md: :sm }
      def derive(name, from:, values:)
        declare_option(:derive, name:, from: from.to_sym, values: normalize_derived_values(values))
      end

      # Merges values into an inherited derived value, e.g. for values an
      # extension adds to its option.
      def extend_derived(name, values:)
        declare_option(:extend_derived, name:, values: normalize_derived_values(values))
      end

      def remove_derived(name)
        declare_option(:remove_derived, name:)
      end

      # The resolved options of this class, including inherited declarations.
      #
      # @return [Gustwave::Options::Definition]
      # @raise [Gustwave::DefinitionError] if the declarations are inconsistent.
      def option_definition
        if @option_definition.nil? || @option_definition_version != Options.version
          parent = superclass.option_definition if superclass.respond_to?(:option_definition)
          @option_definition = Definition.build(name || inspect, parent, @option_declarations || [])
          @option_definition_version = Options.version
        end
        @option_definition
      end

      # @return [Object] the default value of an option.
      def option_default(name)
        declared_option(name).default
      end

      # @return [Array<Symbol>] the values of an option, including a
      #   variant's implicit +:none+.
      def option_values(name)
        option = option_definition.enum_option(name.to_sym)
        return option.values if option

        raise UnknownOptionError.new(self.name || inspect, given: name,
                                     expected: option_definition.options.values.reject(&:boolean?).map(&:name))
      end

      private

      # Records a declaration. Gustwave::Styling declares the options of its
      # variants and toggles through it, too.
      def declare_option(action, name:, **args)
        (@option_declarations ||= []) << [ action, { name: name.to_sym, **args } ]
        Options.changed!
        nil
      end

      def declared_option(name)
        option_definition.option(name.to_sym) ||
          raise(UnknownOptionError.new(self.name || inspect, given: name, expected: option_definition.options.keys))
      end

      def normalize_option_values(values)
        Array(values).map { |value| Options.normalize_value(value) }
      end

      def normalize_derived_values(values)
        values.to_h { |value, result| [ Options.normalize_value(value), result ] }.freeze
      end
    end

    # Selects the values a caller passed for this instance's options, usually
    # the initializer's keyword arguments. Read them back with +option_value+
    # rather than using the arguments directly:
    #
    #   def initialize(tag: DEFAULT, scheme: DEFAULT, pill: false)
    #     select_options(tag:, scheme:, pill:)
    #     @tag = option_value(:tag) # not the tag: argument
    #   end
    #
    # Selecting does what the raw argument doesn't:
    # * It resolves +DEFAULT+ and +nil+ to the default the class declares, so
    #   the default lives in the DSL, where subclasses and extensions can
    #   change it, instead of in each initializer's signature.
    # * It validates the value against the option's values: unknown options
    #   or values raise outside production and fall back to the default in
    #   production.
    # * It normalizes the value: strings and numbers become symbols, e.g.
    #   <tt>"sm"</tt> becomes +:sm+, and a toggle's value becomes +true+ or
    #   +false+.
    # * It feeds everything else that reads options, i.e.
    #   +derived_value+ and, with Gustwave::Styling, +classes+,
    #   +attributes_for+, +unless:+ and +per:+, so they all agree with the
    #   value the component renders.
    #
    # Merges with earlier calls, e.g. for an option only known in
    # +before_render+.
    def select_options(**selection)
      option_selection.merge!(normalize_option_selection(selection))
      self
    end

    # @return [Object] the value in effect for an option: the selected one or
    #   the default. +true+ or +false+ for a toggle. Options given here
    #   override the selection for this call.
    def option_value(name, **overrides)
      values = option_values_for(overrides)
      name = name.to_sym
      return values[name] if values.key?(name)

      raise UnknownOptionError.new(option_component_name, given: name, expected: values.keys)
    end

    # Returns a derived value for the value its option has in effect, or
    # +nil+ for an implicit +:none+ it doesn't cover. Options given here
    # override the selection for this call.
    #
    #   derived_value(:icon_size)
    #   derived_value(:icon_size, size: :sm)
    #
    # @raise [UnknownDerivedValueError] if the component derives no such value.
    def derived_value(name, **overrides)
      definition = self.class.option_definition
      derived = definition.derived(name.to_sym) ||
        raise(UnknownDerivedValueError.new(option_component_name, given: name.to_sym, expected: definition.derived_values.keys))

      derived.values[option_values_for(overrides)[derived.from]]
    end

    # @see Gustwave::Options::ClassMethods#option_default
    def option_default(name)
      self.class.option_default(name)
    end

    private

    def option_component_name
      self.class.name || self.class.inspect
    end

    def option_selection
      @option_selection ||= {}
    end

    # @return [Hash{Symbol => Object}] every option's value in effect, with
    #   +overrides+ applied.
    def option_values_for(overrides)
      self.class.option_definition.defaults.merge(option_selection, normalize_option_selection(overrides))
    end

    def normalize_option_selection(selection)
      definition = self.class.option_definition
      selection.each_with_object({}) do |(name, value), normalized|
        name = name.to_sym
        option = definition.option(name)
        unless option
          raise UnknownOptionError.new(option_component_name, given: name, expected: definition.options.keys) if Gustwave.strict?

          next
        end
        next if value.nil? || value.equal?(DEFAULT)

        if option.boolean?
          normalized[name] = ActiveModel::Type::Boolean.new.cast(value) || false
        else
          value = Options.normalize_value(value)
          next normalized[name] = value if option.values.include?(value)
          raise UnknownValueError.new(option_component_name, name, given: value, expected: option.values, fallback: option.default) if Gustwave.strict?
        end
      end
    end
  end
end
